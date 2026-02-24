#include "emcobject.h"

#include "emcglb.h"
#include "../shcom.hh"

#include <QSettings>
#include <QTimerEvent>

#include <QDebug>

QtEMC::QtEMC(QObject *parent) : QObject(parent)
{

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

    emcErrorBuffer = 0;
    emcStatusBuffer = 0;
    emcStatus = 0;
    emcCommandBuffer = 0;

    error_string[LINELEN-1] = 0;
    operator_text_string[LINELEN-1] = 0;
    operator_display_string[LINELEN-1] = 0;
    programStartLine = 0;
}

void QtEMC::thisQuit()
{
    if (0 != emcStatusBuffer) {
        // wait until current message has been received
        emcCommandWaitReceived();
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
    if (0 != tryNml(0.0, 0.0)) {
        qWarning("error in emc connection");
        thisQuit();
        return -1;
    }

    // get current serial number, and save it for restoring when we quit
    // so as not to interfere with real operator interface
    updateStatus();
    emcCommandSerialNumber = emcStatus->echo_serial_number;

    // load vcp parameters from configuration file
    QSettings ini(emc_inifile, QSettings::IniFormat);
    m_machine = ini.value("EMC/MACHINE", "QtEMC").toString();

    // get cycle time, and setup operator interface update timer
    syncTimerId = startTimer(ini.value("DISPLAY/CYCLE_TIME").toReal() * 1000);
    emcTimeout = 0.0;

    for(int j = 0; j < ini.value("KINS/JOINTS", 0).toInt(); ++j)
    {
        QJoint *qjoint = new QJoint;
        m_joints.append(qjoint);

        qjoint->m_minimum = emcStatus->motion.joint[j].minPositionLimit;
        qjoint->m_maximum = emcStatus->motion.joint[j].maxPositionLimit;

        qjoint->m_type = emcStatus->motion.joint[j].jointType;
        qjoint->m_units = emcStatus->motion.joint[j].units;
    }

    // notify initialization finished
    emit sig_init();

    return 0;
}

void QtEMC::timerEvent(QTimerEvent *event)
{
    if (event->timerId() != syncTimerId)
        return;

    if (emcUpdateType == EMC_UPDATE_AUTO)
        updateStatus();

    set_estop(emcStatus->task.state == EMC_TASK_STATE::ESTOP);
    set_power(emcStatus->task.state == EMC_TASK_STATE::ON);

    set_mode(static_cast<int>(emcStatus->task.mode));
    // set_traj(static_cast<int>(emcStatus->motion.traj.mode));

    update_motion();
}

void QtEMC::set_estop(bool value)
{
    if (m_estop == value)
        return;

    if (value)
        sendEstop();
    else
        sendEstopReset();

    m_estop = value;
    emit sig_estop(value);
}

void QtEMC::set_power(bool value)
{
    if (m_power == value)
        return;

    if (value)
        sendMachineOn();
    else
        sendMachineOff();

    m_power = value;
    emit sig_power(value);
}

void QtEMC::set_mode(int value)
{
    if (m_mode == value)
        return;

    switch (static_cast<EMC_TASK_MODE>(value))
    {
	case EMC_TASK_MODE::MANUAL:
	    sendManual();
	    break;
	case EMC_TASK_MODE::AUTO:
	    sendAuto();
	    break;
	case EMC_TASK_MODE::MDI:
	    sendMdi();
	    break;
	default:
	    sendEstop();
	    break;
	}

    m_mode = value;
    emit sig_mode(value);
}

void QtEMC::set_traj(int value)
{
    if (m_traj == value)
        return;

    sendSetTeleopEnable(value);

    m_traj = value;
    emit sig_traj(value);
}

void QtEMC::override_feed(double value)
{
    if (m_feed == value)
        return;

    sendFeedOverride(value);

    m_feed = value;
    emit sig_feed(value);
}

void QtEMC::override_rapid(double value)
{
    if (m_rapid == value)
        return;

    sendRapidOverride(value);

    m_rapid = value;
    emit sig_rapid(value);
}

void QtEMC::set_home(int joint, bool home)
{
    if (home)
        sendHome(joint);
    else
        sendUnHome(joint);
}

QObject *QtEMC::joint(int joint)
{
    return m_joints.at(joint);
}

void QtEMC::jog(int joint, int speed)
{
    sendJogCont(joint, JOGJOINT, 100.0 / speed);
}

void QtEMC::jog_stop(int joint)
{
    sendJogStop(joint, JOGJOINT);
}

void QtEMC::move(int axis, int speed)
{
    sendJogCont(axis, JOGTELEOP, 100.0 / speed);
}

void QtEMC::move_stop(int axis)
{
    sendJogStop(axis, JOGTELEOP);
}

void QtEMC::update_motion()
{
    for(int j = 0; j < m_joints.size(); ++j)
    {
        QJoint *qjoint = qobject_cast<QJoint *>(m_joints[j]);

        qjoint->m_inpos = emcStatus->motion.joint[j].inpos;
        qjoint->m_homed = emcStatus->motion.joint[j].homed;
        qjoint->m_position = emcStatus->motion.joint[j].input;
        qjoint->m_velocity = emcStatus->motion.joint[j].velocity;

        emit qjoint->sig_joint();
    }

    emit sig_motion();
}