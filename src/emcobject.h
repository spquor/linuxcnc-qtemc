#ifndef EMCOBJECT_H
#define EMCOBJECT_H

#include "emcstructs.h"

// connection between qml and nml

class QtEMC : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QObject* info MEMBER m_info CONSTANT) QObject* m_info;
    Q_PROPERTY(QObject* task MEMBER m_task CONSTANT) QObject* m_task;

    Q_PROPERTY(QObjectList motion MEMBER m_motion CONSTANT) QObjectList m_motion;

public:
    explicit QtEMC(QObject *parent = nullptr);
    ~QtEMC();

    int initEMC(int argc, char *argv[]);

public slots:
    void set_estop(bool value);
    void set_power(bool value);

    void set_mode(int value);
    void set_traj(int value);

    void override_feed(double value);
    void override_rapid(double value);

    QObject* joint(int joint);
    void set_home(int joint, bool home);

    void jog(int joint, int speed);
    void jog_stop(int joint);

    void move(int axis, int speed);
    void move_stop(int axis);

protected:
    void timerEvent(QTimerEvent *event);

private:
    void thisInit();
    void thisQuit();

    int syncTimerId;
};

#endif // EMCOBJECT_H
