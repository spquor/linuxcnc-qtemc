#include "deviceio.h"

#include <iio.h>
#include <gpiod.h>

namespace {

    gpiod_chip *gpio_chip0;
    gpiod_chip *gpio_chip1;
    gpiod_chip *gpio_chip2;

    gpiod_line *e_stop_no_ln;
    gpiod_line *e_stop_nc_ln;
    gpiod_line *button1_ln;
    gpiod_line *button2_ln;
    gpiod_line *button3_ln;
    gpiod_line *button4_ln;
    gpiod_line *move_ok_ln;

    int *e_stop_no_value;
    int *e_stop_nc_value;
    int *button1_value;
    int *button2_value;
    int *button3_value;
    int *button4_value;
    int *move_ok_value;

    iio_context *iio_ctx;
    iio_device *iio_dev;

    iio_channel *joy_x_chn;
    iio_channel *joy_y_chn;
    iio_channel *joy_z_chn;

    iio_buffer *joy_x_buf;
    iio_buffer *joy_y_buf;
    iio_buffer *joy_z_buf;

}

QtIO::QtIO(QObject *parent) : QObject(parent)
{
    iio_ctx = iio_create_local_context();
}

QtIO::~QtIO()
{
    iio_context_destroy(iio_ctx);
}

void QtIO::timerEvent(QTimerEvent *event)
{

}
