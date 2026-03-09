TEMPLATE = app
TARGET = qtemc

SOURCES += \
    ext/shcom.cc \
    src/emcobject.cpp \
    src/qtemc.cpp

HEADERS += \
    ext/shcom.hh \
    src/emcobject.h \
    src/emcstructs.h

QML_FILES += \
    qml/vcp.qml

DEFINES += ULAPI

QT = core gui qml quick

isEmpty(LINUXCNC_DIR) {
    LINUXCNC_DIR = ../linuxcnc/
}
DESTDIR = obj
OBJECTS_DIR = obj
MOC_DIR = obj

INCLUDEPATH += $${LINUXCNC_DIR}/include
LIBS += $${LINUXCNC_DIR}/lib/liblinuxcnc.a
LIBS += $${LINUXCNC_DIR}/lib/libnml.so.0
LIBS += $${LINUXCNC_DIR}/lib/liblinuxcncini.so.0
LIBS += $${LINUXCNC_DIR}/lib/liblinuxcnchal.so.0
LIBS += $${LINUXCNC_DIR}/lib/libtooldata.so.0

target.files = $${TARGET}
target.path = $${LINUXCNC_DIR}/bin

style.files = $${QML_FILES}
style.path = $${LINUXCNC_DIR}/share/linuxcnc

INSTALLS += target style
