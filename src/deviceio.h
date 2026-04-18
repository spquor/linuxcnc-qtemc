#ifndef DEVICEIO_H
#define DEVICEIO_H

#include <QObject>

class QtIO : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int stop_no MEMBER m_stop_no NOTIFY sig_estop) int m_stop_no;
    Q_PROPERTY(int stop_nc MEMBER m_stop_nc NOTIFY sig_estop) int m_stop_nc;
    Q_PROPERTY(int move_ok MEMBER m_move_ok NOTIFY sig_move) int m_move_ok;

    Q_PROPERTY(int button1 MEMBER m_button1 NOTIFY sig_button1) int m_button1;
    Q_PROPERTY(int button2 MEMBER m_button2 NOTIFY sig_button2) int m_button2;
    Q_PROPERTY(int button3 MEMBER m_button3 NOTIFY sig_button3) int m_button3;
    Q_PROPERTY(int button4 MEMBER m_button4 NOTIFY sig_button4) int m_button4;

    Q_PROPERTY(long long joy_x MEMBER m_joy_x NOTIFY sig_joystick) long long m_joy_x;
    Q_PROPERTY(long long joy_y MEMBER m_joy_y NOTIFY sig_joystick) long long m_joy_y;
    Q_PROPERTY(long long joy_z MEMBER m_joy_z NOTIFY sig_joystick) long long m_joy_z;

public:
    explicit QtIO(QObject *parent = nullptr);
    ~QtIO();

protected:
    void timerEvent(QTimerEvent *event);

    Q_SIGNAL void sig_estop(bool value);
    Q_SIGNAL void sig_move(bool value);

    Q_SIGNAL void sig_button1(bool value);
    Q_SIGNAL void sig_button2(bool value);
    Q_SIGNAL void sig_button3(bool value);
    Q_SIGNAL void sig_button4(bool value);

    Q_SIGNAL void sig_joystick(int x, int y, int z);

private:
    bool readAnalogValue(long long &member, long long value)
    {
        const bool need_update = (abs(member - value) > 4);

        if (need_update) {
            member = value;
        }

        return need_update;
    }

    bool readDigitalValue(int &member, int value)
    {
        const bool need_update = (member != value);

        if (need_update) {
            member = value;
        }

        return need_update;
    }

    int syncTimerId;
};

#endif // DEVICEIO_H
