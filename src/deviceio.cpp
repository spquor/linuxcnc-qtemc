#include "deviceio.h"

#include <QSettings>
#include <QTimerEvent>

#include <QDebug>

#include <iio.h>
#include <gpiod.h>

namespace {

gpiod_chip *gpio_chip0;
gpiod_chip *gpio_chip1;
gpiod_chip *gpio_chip2;
gpiod_chip *gpio_chip3;

gpiod_line *stop_no_ln;
gpiod_line *stop_nc_ln;
gpiod_line *move_ok_ln;
gpiod_line *button1_ln;
gpiod_line *button2_ln;
gpiod_line *button3_ln;
gpiod_line *button4_ln;

iio_context *iio_ctx;
iio_device *iio_dev;

iio_channel *joy_x_chn;
iio_channel *joy_y_chn;
iio_channel *joy_z_chn;

}

QtIO::QtIO(QObject *parent) : QObject(parent)
{
    gpio_chip0 = gpiod_chip_open("/dev/gpiochip0");
    gpio_chip1 = gpiod_chip_open("/dev/gpiochip1");
    gpio_chip2 = gpiod_chip_open("/dev/gpiochip2");
    gpio_chip3 = gpiod_chip_open("/dev/gpiochip3");

    if (gpio_chip0 && gpio_chip0 && gpio_chip0 && gpio_chip3 != nullptr)
    {
        stop_no_ln = gpiod_chip_get_line(gpio_chip2, 2);
        if (!stop_no_ln || !gpiod_line_request_input(stop_no_ln, "qtemc"))
            qWarning("gpio line [stop_no] request failed");

        stop_nc_ln = gpiod_chip_get_line(gpio_chip2, 5);
        if (!stop_nc_ln || !gpiod_line_request_input(stop_nc_ln, "qtemc"))
            qWarning("gpio line [stop_nc] request failed");

        move_ok_ln = gpiod_chip_get_line(gpio_chip0, 22);
        if (!move_ok_ln || !gpiod_line_request_input(move_ok_ln, "qtemc"))
            qWarning("gpio line [move_ok] request failed");

        button1_ln = gpiod_chip_get_line(gpio_chip1, 13);
        if (!button1_ln || !gpiod_line_request_input(button1_ln, "qtemc"))
            qWarning("gpio line [button1] request failed");

        button2_ln = gpiod_chip_get_line(gpio_chip0, 23);
        if (!button2_ln || !gpiod_line_request_input(button2_ln, "qtemc"))
            qWarning("gpio line [button2] request failed");

        button3_ln = gpiod_chip_get_line(gpio_chip1, 15);
        if (!button3_ln || !gpiod_line_request_input(button3_ln, "qtemc"))
            qWarning("gpio line [button3] request failed");

        button4_ln = gpiod_chip_get_line(gpio_chip0, 27);
        if (!button4_ln || !gpiod_line_request_input(button4_ln, "qtemc"))
            qWarning("gpio line [button4] request failed");
    }
    else
    {
        qFatal("cannot open gpio chips");
    }

    iio_ctx = iio_create_local_context();
    iio_dev = iio_context_find_device(iio_ctx, "iio:device0");

    if (iio_dev != nullptr)
    {
        joy_x_chn = iio_device_find_channel(iio_dev, "voltage0", false);
        if (joy_x_chn == nullptr)
            qWarning("iio channel [joy_x] request failed");

        joy_y_chn = iio_device_find_channel(iio_dev, "voltage2", false);
        if (joy_y_chn == nullptr)
            qWarning("iio channel [joy_y] request failed");

        joy_z_chn = iio_device_find_channel(iio_dev, "voltage4", false);
        if (joy_z_chn == nullptr)
            qWarning("iio channel [joy_z] request failed");
    }
    else
    {
        qFatal("cannot open iio device");
    }

    syncTimerId = startTimer(10);
}

QtIO::~QtIO()
{
    gpiod_line_release(stop_no_ln);
    gpiod_line_release(stop_nc_ln);
    gpiod_line_release(move_ok_ln);
    gpiod_line_release(button1_ln);
    gpiod_line_release(button2_ln);
    gpiod_line_release(button3_ln);
    gpiod_line_release(button4_ln);

    gpiod_chip_close(gpio_chip0);
    gpiod_chip_close(gpio_chip1);
    gpiod_chip_close(gpio_chip2);
    gpiod_chip_close(gpio_chip3);

    iio_context_destroy(iio_ctx);
}

void QtIO::timerEvent(QTimerEvent *event)
{
    if (event->timerId() != syncTimerId)
        return;

    const bool upd_stop_no = readDigitalValue(m_stop_no, gpiod_line_get_value(stop_no_ln));
    const bool upd_stop_nc = readDigitalValue(m_stop_nc, gpiod_line_get_value(stop_nc_ln));

    if (upd_stop_no || upd_stop_nc)
        emit sig_estop(m_stop_no || !m_stop_nc);


    if (readDigitalValue(m_move_ok, gpiod_line_get_value(move_ok_ln)))
        emit sig_move(m_move_ok);


    if (readDigitalValue(m_button1, gpiod_line_get_value(button1_ln)))
        emit sig_button1(m_button1);

    if (readDigitalValue(m_button2, gpiod_line_get_value(button2_ln)))
        emit sig_button2(m_button2);

    if (readDigitalValue(m_button3, gpiod_line_get_value(button3_ln)))
        emit sig_button3(m_button3);

    if (readDigitalValue(m_button4, gpiod_line_get_value(button4_ln)))
        emit sig_button4(m_button4);


    long long joy_x, joy_y, joy_z;

    iio_channel_attr_read_longlong(joy_x_chn, "raw", &joy_x);
    iio_channel_attr_read_longlong(joy_y_chn, "raw", &joy_y);
    iio_channel_attr_read_longlong(joy_z_chn, "raw", &joy_z);

    const bool upd_x = readAnalogValue(m_joy_x, joy_x);
    const bool upd_y = readAnalogValue(m_joy_y, joy_y);
    const bool upd_z = readAnalogValue(m_joy_z, joy_z);

    if (upd_x || upd_y || upd_z)
        emit sig_joystick(m_joy_x, m_joy_y, m_joy_z);
}
