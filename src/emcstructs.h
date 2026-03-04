#ifndef EMCSTRUCTS_H
#define EMCSTRUCTS_H

#include <QObject>

class QJoint : public QObject
{
    Q_OBJECT

    Q_PROPERTY(unsigned char type READ what_type NOTIFY sig_joint) unsigned char m_type;
    Q_PROPERTY(double units READ what_units NOTIFY sig_joint) double m_units;
    Q_PROPERTY(unsigned char inpos READ is_inpos NOTIFY sig_joint) double m_inpos;
    Q_PROPERTY(unsigned char homed READ is_homed NOTIFY sig_joint) double m_homed;
    Q_PROPERTY(double position READ what_position NOTIFY sig_joint) double m_position;
    Q_PROPERTY(double velocity READ what_velocity NOTIFY sig_joint) double m_velocity;
    Q_PROPERTY(double minimum READ what_minimum NOTIFY sig_joint) double m_minimum;
    Q_PROPERTY(double maximum READ what_maximum NOTIFY sig_joint) double m_maximum;

public:
    Q_SIGNAL void sig_joint();

    unsigned char what_type() { return m_type; }
    double what_units() { return m_units; }
    unsigned char is_inpos() { return m_inpos; }
    unsigned char is_homed() { return m_homed; }
    double what_position() { return m_position; }
    double what_velocity() { return m_velocity; }
    double what_minimum() { return m_minimum; }
    double what_maximum() { return m_maximum; }

    friend class QtEMC;
};

#endif // EMCSTRUCTS_H
