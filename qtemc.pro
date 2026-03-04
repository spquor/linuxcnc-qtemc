TEMPLATE = app
TARGET = qtemc

SOURCES += \
    ext/shcom.cc \
    src/qtemc.cpp \
    src/emcobject.cpp

HEADERS += \
    ext/shcom.hh \
    src/emcobject.h \
    src/emcstructs.h

DEFINES += ULAPI

QT = core gui qml quick

RIP_DIR = ../linuxcnc/
DESTDIR = $${RIP_DIR}/bin

OBJECTS_DIR = obj
MOC_DIR = obj

INCLUDEPATH += $${RIP_DIR}/include
INCLUDEPATH += $${RIP_DIR}/src

LIBS += $${RIP_DIR}/lib/liblinuxcnc.a
LIBS += $${RIP_DIR}/lib/libnml.so.0
LIBS += $${RIP_DIR}/lib/liblinuxcncini.so.0
LIBS += $${RIP_DIR}/lib/liblinuxcnchal.so.0
LIBS += $${RIP_DIR}/lib/libtooldata.so.0

target.files = $${TARGET}
target.path = $${RIP_DIR}/bin

style.files = $${QML_FILES}
style.path = $${RIP_DIR}/share/linuxcnc

INSTALLS += target style
