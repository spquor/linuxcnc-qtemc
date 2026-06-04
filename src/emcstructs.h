#ifndef EMCSTRUCTS_H
#define EMCSTRUCTS_H

#include <QObject>

class QEmcEnums : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int statusUnknown MEMBER m_statusUnknown CONSTANT) int m_statusUnknown;
    Q_PROPERTY(int statusDone MEMBER m_statusDone CONSTANT) int m_statusDone;
    Q_PROPERTY(int statusExec MEMBER m_statusExec CONSTANT) int m_statusExec;
    Q_PROPERTY(int statusError MEMBER m_statusError CONSTANT) int m_statusError;

    Q_PROPERTY(int stateMenu MEMBER m_stateMenu CONSTANT) int m_stateMenu;
    Q_PROPERTY(int stateManual MEMBER m_stateManual CONSTANT) int m_stateManual;
    Q_PROPERTY(int stateAuto MEMBER m_stateAuto CONSTANT) int m_stateAuto;
    Q_PROPERTY(int stateProgram MEMBER m_stateProgram CONSTANT) int m_stateProgram;

    Q_PROPERTY(int menuEdit MEMBER m_menuEdit CONSTANT) int m_menuEdit = 0;
    Q_PROPERTY(int menuSettings MEMBER m_menuSettings CONSTANT) int m_menuSettings = 1;
    Q_PROPERTY(int menuCommand MEMBER m_menuCommand CONSTANT) int m_menuCommand = 2;
    Q_PROPERTY(int menuFile MEMBER m_menuFile CONSTANT) int m_menuFile = 3;

    Q_PROPERTY(int msgAbout MEMBER m_msgAbout CONSTANT) int m_msgAbout = 0;
    Q_PROPERTY(int msgError MEMBER m_msgError CONSTANT) int m_msgError = 1;
    Q_PROPERTY(int msgOpText MEMBER m_msgOpText CONSTANT) int m_msgOpText = 2;
    Q_PROPERTY(int msgOpDisp MEMBER m_msgOpDisp CONSTANT) int m_msgOpDisp = 3;

public:
    explicit QEmcEnums(QObject *parent) : QObject(parent) {}

    friend class QtEMC;
};

class QEmcInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString machine MEMBER m_machine NOTIFY sig_init) QString m_machine;
    Q_PROPERTY(QString version MEMBER m_version NOTIFY sig_init) QString m_version;

    Q_PROPERTY(int msgtype MEMBER m_msgtype NOTIFY sig_msg) int m_msgtype;
    Q_PROPERTY(QStringList msg MEMBER m_msg NOTIFY sig_msg) QStringList m_msg;

    Q_PROPERTY(int jointnum MEMBER m_jointnum NOTIFY sig_init) int m_jointnum;
    Q_PROPERTY(QStringList axes MEMBER m_axes NOTIFY sig_init) QStringList m_axes;

    Q_PROPERTY(int initjogspd MEMBER m_initjogspd NOTIFY sig_init) int m_initjogspd;
    Q_PROPERTY(int maxjogspd MEMBER m_maxjogspd NOTIFY sig_init) int m_maxjogspd;
    Q_PROPERTY(int initspinspd MEMBER m_initspinspd NOTIFY sig_init) int m_initspinspd;
    Q_PROPERTY(int maxspinspd MEMBER m_maxspinspd NOTIFY sig_init) int m_maxspinspd;

    Q_PROPERTY(int initfeed MEMBER m_initfeed NOTIFY sig_init) int m_initfeed;
    Q_PROPERTY(int maxfeed MEMBER m_maxfeed NOTIFY sig_init) int m_maxfeed;
    Q_PROPERTY(int initrapid MEMBER m_initrapid NOTIFY sig_init) int m_initrapid;
    Q_PROPERTY(int maxrapid MEMBER m_maxrapid NOTIFY sig_init) int m_maxrapid;

public:
    explicit QEmcInfo(QObject *parent) : QObject(parent) {}

    Q_SIGNAL void sig_init();
    Q_SIGNAL void sig_msg();

    friend class QtEMC;
};

class QMachine : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool estop MEMBER m_estop NOTIFY sig_estop) bool m_estop;
    Q_PROPERTY(bool power MEMBER m_power NOTIFY sig_power) bool m_power;
    Q_PROPERTY(bool menu MEMBER m_menu NOTIFY sig_menu) bool m_menu;
    Q_PROPERTY(int stat MEMBER m_stat NOTIFY sig_stat) int m_stat;
    Q_PROPERTY(int mode MEMBER m_mode NOTIFY sig_mode) int m_mode;
    Q_PROPERTY(int traj MEMBER m_traj NOTIFY sig_traj) int m_traj;
    Q_PROPERTY(double feed MEMBER m_feed NOTIFY sig_feed) double m_feed;
    Q_PROPERTY(double rapid MEMBER m_rapid NOTIFY sig_rapid) double m_rapid;

public:
    explicit QMachine(QObject *parent) : QObject(parent) {}

    Q_SIGNAL void sig_estop(bool value);
    Q_SIGNAL void sig_power(bool value);
    Q_SIGNAL void sig_menu(bool value);
    Q_SIGNAL void sig_stat(int value);
    Q_SIGNAL void sig_mode(int value);
    Q_SIGNAL void sig_traj(int value);
    Q_SIGNAL void sig_feed(double value);
    Q_SIGNAL void sig_rapid(double value);

    friend class QtEMC;
};

class QJoint : public QObject
{
    Q_OBJECT

    Q_PROPERTY(unsigned char type MEMBER m_type NOTIFY sig_motion) unsigned char m_type;
    Q_PROPERTY(double units MEMBER m_units NOTIFY sig_motion) double m_units;
    Q_PROPERTY(unsigned char inpos MEMBER m_inpos NOTIFY sig_motion) double m_inpos;
    Q_PROPERTY(unsigned char homed MEMBER m_homed NOTIFY sig_motion) double m_homed;
    Q_PROPERTY(double position MEMBER m_position NOTIFY sig_motion) double m_position;
    Q_PROPERTY(double velocity MEMBER m_velocity NOTIFY sig_motion) double m_velocity;
    Q_PROPERTY(double minimum MEMBER m_minimum NOTIFY sig_motion) double m_minimum;
    Q_PROPERTY(double maximum MEMBER m_maximum NOTIFY sig_motion) double m_maximum;

public:
    explicit QJoint(QObject *parent) : QObject(parent) {}

    Q_SIGNAL void sig_motion();

    friend class QtEMC;
};

class QProgram : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name MEMBER m_name NOTIFY sig_name) QString m_name;
    Q_PROPERTY(QString text MEMBER m_text NOTIFY sig_text) QString m_text;
    Q_PROPERTY(int linenum MEMBER m_linenum NOTIFY sig_linenum) int m_linenum;
    Q_PROPERTY(int suspend MEMBER m_suspend NOTIFY sig_suspend) int m_suspend;
    Q_PROPERTY(bool optstop MEMBER m_optstop NOTIFY sig_optstop) bool m_optstop;
    Q_PROPERTY(bool blockrm MEMBER m_blockrm NOTIFY sig_blockrm) bool m_blockrm;
    Q_PROPERTY(QStringList gcodes MEMBER m_gcodes NOTIFY sig_gcodes) QStringList m_gcodes;
    Q_PROPERTY(QStringList mcodes MEMBER m_mcodes NOTIFY sig_mcodes) QStringList m_mcodes;

public:
    explicit QProgram(QObject *parent) : QObject(parent) {}

    Q_SIGNAL void sig_name(QString);
    Q_SIGNAL void sig_text(QString);
    Q_SIGNAL void sig_linenum(int);
    Q_SIGNAL void sig_suspend(int);
    Q_SIGNAL void sig_optstop(bool);
    Q_SIGNAL void sig_blockrm(bool);
    Q_SIGNAL void sig_gcodes(QStringList);
    Q_SIGNAL void sig_mcodes(QStringList);

    friend class QtEMC;
};

#endif // EMCSTRUCTS_H
