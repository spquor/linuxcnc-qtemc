#include <QGuiApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "emcobject.h"
#include "deviceio.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QGuiApplication app(argc, argv);

    QtEMC *qtEMC = new QtEMC(&app);
    QtIO *qtDevIO = new QtIO(&app);

    if (qtEMC->initEMC(argc, argv) == -1)
        return -1;

    const QString &qmlPath =
        QProcessEnvironment::systemEnvironment().value("VCP_QML", "./vcp.qml");

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("emc", qtEMC);
    engine.rootContext()->setContextProperty("io", qtDevIO);

    engine.load(QUrl(qmlPath));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
