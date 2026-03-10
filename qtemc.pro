TEMPLATE = app
TARGET = qtemc

SOURCES += \
    src/shcom.cc \
    src/emcobject.cpp \
    src/qtemc.cpp

HEADERS += \
    src/shcom.hh \
    src/emcobject.h \
    src/emcstructs.h

QML_FILES += \
    config/vcp.qml

EMC_FILES += \
    config/bone.hal \
    config/tool.tbl \
    config/example.ngc \
    config/bone.ini

DEFINES += ULAPI

QT = core gui qml quick

isEmpty(LINUXCNC_DIR) {
    LINUXCNC_DIR = ../linuxcnc/
}
DESTDIR = obj
OBJECTS_DIR = obj
MOC_DIR = obj

INCLUDEPATH += $${LINUXCNC_DIR}/include
INCLUDEPATH += $${LINUXCNC_DIR}/include/linuxcnc

LIBS += -L$${LINUXCNC_DIR}/lib/
LIBS += -llinuxcnc -lnml -llinuxcncini -llinuxcnchal -ltooldata

target.files = $${DESTDIR}/$${TARGET}
target.path = $${LINUXCNC_DIR}/bin

style.files = $${QML_FILES} $${EMC_FILES}
style.path = $${LINUXCNC_DIR}/share/linuxcnc

INSTALLS += target style
