#ifndef EMCOBJECT_H
#define EMCOBJECT_H

#include "emcstructs.h"

class QtEMC : public QObject
{
    Q_OBJECT

    // read-only properties loaded inside init function
    Q_PROPERTY(QString machine READ what_machine NOTIFY sig_init) QString m_machine;

    // read-write main control properties
    Q_PROPERTY(bool estop READ is_estop WRITE set_estop NOTIFY sig_estop) bool m_estop;
    Q_PROPERTY(bool power READ is_power WRITE set_power NOTIFY sig_power) bool m_power;

    Q_PROPERTY(int mode READ what_mode WRITE set_mode NOTIFY sig_mode) int m_mode;
    Q_PROPERTY(int traj READ what_traj WRITE set_traj NOTIFY sig_traj) int m_traj;

    Q_PROPERTY(double feed READ what_feed WRITE override_feed NOTIFY sig_feed) double m_feed;
    Q_PROPERTY(double rapid READ what_rapid WRITE override_rapid NOTIFY sig_rapid) double m_rapid;

    // read-only properties indicating every joint status
    Q_PROPERTY(QObjectList joints READ motion_stat NOTIFY sig_motion) QObjectList m_joints;

public:
    explicit QtEMC(QObject *parent = nullptr);
    ~QtEMC();

    int initEMC(int argc, char *argv[]);

    QString what_machine() const { return m_machine; }
    Q_SIGNAL void sig_init();

    bool is_estop() const { return m_estop; }
    Q_SLOT void set_estop(bool value);
    Q_SIGNAL void sig_estop(bool value);

    bool is_power() const { return m_power; }
    Q_SLOT void set_power(bool value);
    Q_SIGNAL void sig_power(bool value);

    int what_mode() const { return m_mode; }
    Q_SLOT void set_mode(int value);
    Q_SIGNAL void sig_mode(int value);

    int what_traj() const { return m_traj; }
    Q_SLOT void set_traj(int value);
    Q_SIGNAL void sig_traj(int value);

    double what_feed() const { return m_feed; }
    Q_SLOT void override_feed(double value);
    Q_SIGNAL void sig_feed(double value);

    double what_rapid() const { return m_rapid; }
    Q_SLOT void override_rapid(double value);
    Q_SIGNAL void sig_rapid(double value);

    QObjectList motion_stat() { return m_joints; }
    Q_SLOT void update_motion();
    Q_SIGNAL void sig_motion();

    Q_SLOT void set_home(int joint, bool home);
    Q_SLOT QObject *joint(int joint);

    Q_SLOT void jog(int joint, int speed);
    Q_SLOT void jog_stop(int joint);

    Q_SLOT void move(int axis, int speed);
    Q_SLOT void move_stop(int axis);

protected:
    void timerEvent(QTimerEvent *event);

private:
    void thisInit();
    void thisQuit();

    int syncTimerId;

};

#endif // EMCOBJECT_H
