TEMPLATE = app
TARGET = qtemc

SOURCES += \
    qtemc.cpp \
    ../shcom.cc \
    emcobject.cpp

HEADERS += \
    qstructs.h \
    ../shcom.hh \
    emcobject.h

QML_FILES += \
    vcp.qml

DEFINES += ULAPI

QT = core gui qml quick
QMAKE_CXXFLAGS += -std=c++20

RIP_DIR = $$_PRO_FILE_PWD_/../../../..
OBJ_DIR = $${RIP_DIR}/src/objects/emc/usr_intf/qtemc

DESTDIR = $${RIP_DIR}/bin
OBJECTS_DIR = $${OBJ_DIR}
MOC_DIR = $${OBJ_DIR}
RCC_DIR = $${OBJ_DIR}

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
