#include "emcobject.h"

#include <QSettings>
#include <QTimerEvent>
#include <QFile>
#include <QDebug>

#include "emcglb.h"
#include "shcom.hh"

QtEMC::QtEMC(QObject *parent) : QObject(parent)
{
    emcErrorBuffer = 0;
    emcStatusBuffer = 0;
    emcStatus = 0;
    emcCommandBuffer = 0;

    m_info = 0;
    m_task = 0;

    syncTimerId = 0;
}

QtEMC::~QtEMC()
{
    thisQuit();
}

void QtEMC::thisInit()
{
    emcWaitType = EMC_WAIT_RECEIVED;
    emcUpdateType = EMC_UPDATE_AUTO;
    linearUnitConversion = LINEAR_UNITS_AUTO;
    angularUnitConversion = ANGULAR_UNITS_AUTO;

    // init NML buffers

    error_string[LINELEN-1] = 0;
    operator_text_string[LINELEN-1] = 0;
    operator_display_string[LINELEN-1] = 0;
    programStartLine = 0;

    // init qml structures

    m_enums = new QEmcEnums(this);
    m_info = new QEmcInfo(this);
    m_task = new QMachine(this);
    m_prog = new QProgram(this);

    for (int j = 0; j < EMCMOT_MAX_JOINTS; ++j)
        m_motion.append(new QJoint(this));
}

void QtEMC::thisQuit()
{
    // wait until current message has been received

    if (0 != emcStatusBuffer) {
        emcCommandWaitReceived();
    }

    // stop event timer

    if (syncTimerId) {
        killTimer(syncTimerId);
    }

    // clean up qml structures

    if (m_info) {
        delete m_info;
        m_info = 0;
    }

    if (m_task) {
        delete m_task;
        m_task = 0;
    }

    if (!m_motion.isEmpty())
    {
        qDeleteAll(m_motion);
        m_motion.clear();
    }

    // clean up NML buffers

    if (emcErrorBuffer != 0) {
        delete emcErrorBuffer;
        emcErrorBuffer = 0;
    }

    if (emcStatusBuffer != 0) {
        delete emcStatusBuffer;
        emcStatusBuffer = 0;
        emcStatus = 0;
    }

    if (emcCommandBuffer != 0) {
        delete emcCommandBuffer;
        emcCommandBuffer = 0;
    }
}

int QtEMC::initEMC(int argc, char *argv[])
{
    // set up default variables
    thisInit();

    // process command line args
    // use -ini inifilename to set EMC_INIFILE
    // see emcargs.c for other arguments
    if (0 != emcGetArgs(argc, (char**)argv)) {
        qWarning("error in argument list");
        thisQuit();
        return -1;
    }

    // get configuration information
    if (0 != iniLoad(emc_inifile)) {
        qWarning("error in ini configuration");
        thisQuit();
        return -1;
    }

    // init NML
    // return if emc is not already running
    if (0 != tryNml()) {
        qWarning("error in emc connection");
        thisQuit();
        return -1;
    }

    // init state enum constants
    QEmcEnums *enums = qobject_cast<QEmcEnums *>(m_enums);

    enums->m_statusUnknown = RCS_STATUS::UNINITIALIZED_STATUS;
    enums->m_statusDone = RCS_STATUS::RCS_DONE;
    enums->m_statusExec = RCS_STATUS::RCS_EXEC;
    enums->m_statusError = RCS_STATUS::RCS_ERROR;

    enums->m_stateMenu = 0;
    enums->m_stateManual = EMC_TASK_MODE_ENUM::EMC_TASK_MODE_MANUAL;
    enums->m_stateAuto = EMC_TASK_MODE_ENUM::EMC_TASK_MODE_AUTO;
    enums->m_stateProgram = EMC_TASK_MODE_ENUM::EMC_TASK_MODE_MDI;

    enums->m_menuEdit = 0;
    enums->m_menuSettings = 1;
    enums->m_menuCommand = 2;
    enums->m_menuFile = 3;

    // get current serial number, and save it for restoring when we quit
    // so as not to interfere with real operator interface
    updateStatus();
    emcCommandSerialNumber = emcStatus->echo_serial_number;

    // load vcp parameters from configuration file
    QSettings ini(emc_inifile, QSettings::IniFormat);
    QEmcInfo* info = qobject_cast<QEmcInfo*>(m_info);

    info->m_machine = ini.value("EMC/MACHINE", "QtEMC").toString();
    info->m_version = ini.value("EMC/VERSION", "QtEMC").toString();
    info->m_jointnum = ini.value("KINS/JOINTS", 0).toInt();
    info->m_axes = ini.value("KINS/COORDINATES", "").toString().split(' ', Qt::SkipEmptyParts);

    prog_open(ini.value("DISPLAY/PROGRAM_PREFIX").toString() +
        ini.value("DISPLAY/OPEN_FILE").toString());

    // get cycle time, and setup operator interface update timer
    syncTimerId = startTimer(ini.value("DISPLAY/CYCLE_TIME").toReal() * 1000);
    emcTimeout = 0.0;

    for(int j = 0; j < info->m_jointnum; ++j)
    {
        QJoint *qjoint = qobject_cast<QJoint *>(m_motion.at(j));

        qjoint->m_minimum = emcStatus->motion.joint[j].minPositionLimit;
        qjoint->m_maximum = emcStatus->motion.joint[j].maxPositionLimit;

        qjoint->m_type = emcStatus->motion.joint[j].jointType;
        qjoint->m_units = emcStatus->motion.joint[j].units;

        emit qjoint->sig_motion();
    }

    emit info->sig_init();

    return 0;
}

void QtEMC::timerEvent(QTimerEvent *event)
{
    if (event->timerId() != syncTimerId)
        return;

    if (emcUpdateType == EMC_UPDATE_AUTO)
        updateStatus();

    if (emcStatus->task.status != RCS_STATUS::RCS_EXEC)
    {
        set_estop(emcStatus->task.state == EMC_TASK_STATE_ENUM::EMC_TASK_STATE_ESTOP);
        set_power(emcStatus->task.state == EMC_TASK_STATE_ENUM::EMC_TASK_STATE_ON);

        set_stat(static_cast<int>(emcStatus->task.status));
        set_mode(static_cast<int>(emcStatus->task.mode));

        set_optstop(emcStatus->task.optional_stop_state);
        set_blockrm(emcStatus->task.block_delete_state);
    }

    if (emcStatus->task.status != RCS_STATUS::UNINITIALIZED_STATUS)
    {
        QProgram *prog = qobject_cast<QProgram *>(m_prog);

        prog->m_linenum = emcStatus->task.motionLine;
        prog->m_suspend = emcStatus->task.task_paused;

        emit prog->sig_linenum(prog->m_linenum);
        emit prog->sig_suspend(prog->m_suspend);

        prog->m_gcodes.clear(); //slow??
        for(int gcode : emcStatus->task.activeGCodes)
            prog->m_gcodes << QString::number(gcode);

        prog->m_mcodes.clear(); //slow??
        for(int mcode : emcStatus->task.activeMCodes)
            prog->m_mcodes << QString::number(mcode);

        emit prog->sig_gcodes(prog->m_gcodes);
        emit prog->sig_mcodes(prog->m_mcodes);
    }

    for(int j = 0; j < m_motion.size(); ++j)
    {
        QJoint *qjoint = qobject_cast<QJoint *>(m_motion.at(j));

        qjoint->m_inpos = emcStatus->motion.joint[j].inpos;
        qjoint->m_homed = emcStatus->motion.joint[j].homed;
        qjoint->m_position = emcStatus->motion.joint[j].input;
        qjoint->m_velocity = emcStatus->motion.joint[j].velocity;

        emit qjoint->sig_motion();
    }
}

void QtEMC::set_estop(bool value)
{
    QMachine* task = qobject_cast<QMachine*>(m_task);

    if (!task || task->m_estop == value)
        return;

    if (value)
        sendEstop();
    else
        sendEstopReset();

    task->m_estop = value;
    emit task->sig_estop(value);
}

void QtEMC::set_power(bool value)
{
    QMachine* task = qobject_cast<QMachine*>(m_task);

    if (!task || task->m_power == value)
        return;

    if (value)
        sendMachineOn();
    else
        sendMachineOff();

    task->m_power = value;
    emit task->sig_power(value);
}

void QtEMC::set_menu(bool value)
{
    QMachine* task = qobject_cast<QMachine*>(m_task);

    if (!task || task->m_menu == value)
        return;

    task->m_menu = value;
    emit task->sig_menu(value);
}

void QtEMC::set_stat(int value)
{
    QMachine* task = qobject_cast<QMachine*>(m_task);

    if (!task || task->m_stat == value)
        return;

    task->m_stat = value;
    emit task->sig_stat(value);
}

void QtEMC::set_mode(int value)
{
    QMachine* task = qobject_cast<QMachine*>(m_task);

    if (!task || task->m_mode == value)
        return;

    switch (static_cast<EMC_TASK_MODE_ENUM>(value))
    {
    case EMC_TASK_MODE_ENUM::EMC_TASK_MODE_MANUAL:
        sendManual();
        break;
    case EMC_TASK_MODE_ENUM::EMC_TASK_MODE_AUTO:
        sendAuto();
        break;
    case EMC_TASK_MODE_ENUM::EMC_TASK_MODE_MDI:
        sendMdi();
        break;
    default:
        sendEstop();
        break;
    }

    task->m_mode = value;
    emit task->sig_mode(value);
}

void QtEMC::set_traj(int value)
{
    QMachine* task = qobject_cast<QMachine*>(m_task);

    if (!task || task->m_traj == value)
        return;

    sendSetTeleopEnable(value);

    task->m_traj = value;
    emit task->sig_traj(value);
}

void QtEMC::set_optstop(bool value)
{
    QProgram* prog = qobject_cast<QProgram*>(m_prog);

    if (!prog || prog->m_optstop == value)
        return;

    sendSetOptionalStop(value);

    prog->m_optstop = value;
    emit prog->sig_optstop(value);
}

void QtEMC::set_blockrm(bool value)
{
    QProgram* prog = qobject_cast<QProgram*>(m_prog);

    if (!prog || prog->m_blockrm == value)
        return;

    // send(value);

    prog->m_blockrm = value;
    emit prog->sig_blockrm(value);
}

void QtEMC::override_feed(double value)
{
    QMachine* task = qobject_cast<QMachine*>(m_task);

    if (!task || task->m_feed == value)
        return;

    sendFeedOverride(value);

    task->m_feed = value;
    emit task->sig_feed(value);
}

void QtEMC::override_rapid(double value)
{
    QMachine* task = qobject_cast<QMachine*>(m_task);

    if (!task || task->m_rapid == value)
        return;

    sendRapidOverride(value);

    task->m_rapid = value;
    emit task->sig_rapid(value);
}

QObject* QtEMC::joint(int joint)
{
    return m_motion.at(joint);
}

void QtEMC::set_home(int joint, bool home)
{
    if (home)
        sendHome(joint);
    else
        sendUnHome(joint);
}

void QtEMC::jog(int joint, int speed)
{
    sendJogCont(joint, JOGJOINT, speed);
}

void QtEMC::jog_stop(int joint)
{
    sendJogStop(joint, JOGJOINT);
}

void QtEMC::move(int axis, int speed)
{
    sendJogCont(axis, JOGTELEOP, speed);
}

void QtEMC::move_stop(int axis)
{
    sendJogStop(axis, JOGTELEOP);
}

void QtEMC::prog_open(QString path)
{
    QByteArray ba = path.toLocal8Bit();
    char *cpath = new char[ba.size() + 1];
    strcpy(cpath, ba.data());
    sendProgramOpen(cpath);

    QFile file = QFile(path);
    if (file.open(QIODevice::ReadOnly))
    {
        QProgram* prog = qobject_cast<QProgram*>(m_prog);
        const QString text = file.readAll();

        prog->m_name = path;
        prog->m_text = text;

        emit prog->sig_name(path);
        emit prog->sig_text(text);
    }
}

void QtEMC::prog_start() {
    sendProgramRun(0);
}
void QtEMC::prog_step() {
    sendProgramStep();
}
void QtEMC::prog_pause() {
    sendProgramPause();
}
void QtEMC::prog_resume() {
    sendProgramResume();
}
void QtEMC::task_init() {
    sendTaskPlanInit();
}
void QtEMC::task_abort() {
    sendAbort();
}
