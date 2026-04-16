#ifndef DEVICEIO_H
#define DEVICEIO_H

#include <QObject>

class QtIO : public QObject
{
    Q_OBJECT

public:
    explicit QtIO(QObject *parent = nullptr);
    ~QtIO();

protected:
    void timerEvent(QTimerEvent *event);

private:

    int syncTimerId;
};

#endif // DEVICEIO_H
