#ifndef EMCSTRUCTS_H
#define EMCSTRUCTS_H

#include <QObject>

class QEmcInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString machine MEMBER m_machine NOTIFY sig_init) QString m_machine;
    Q_PROPERTY(QString version MEMBER m_version NOTIFY sig_init) QString m_version;

public:
    explicit QEmcInfo(QObject *parent) : QObject(parent) {}

    Q_SIGNAL void sig_init();

    friend class QtEMC;
};

class QMachine : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool estop MEMBER m_estop NOTIFY sig_estop) bool m_estop;
    Q_PROPERTY(bool power MEMBER m_power NOTIFY sig_power) bool m_power;
    Q_PROPERTY(int mode MEMBER m_mode NOTIFY sig_mode) int m_mode;
    Q_PROPERTY(int traj MEMBER m_traj NOTIFY sig_traj) int m_traj;
    Q_PROPERTY(double feed MEMBER m_feed NOTIFY sig_feed) double m_feed;
    Q_PROPERTY(double rapid MEMBER m_rapid NOTIFY sig_rapid) double m_rapid;

public:
    explicit QMachine(QObject *parent) : QObject(parent) {}

    Q_SIGNAL void sig_estop(bool value);
    Q_SIGNAL void sig_power(bool value);
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

#endif // EMCSTRUCTS_H
