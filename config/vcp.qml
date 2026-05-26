import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.VirtualKeyboard 2.15

ApplicationWindow {
    visible: true
    title: qsTr("LinuxCNC")
    width: 1280
    height: 720

    palette.window: "black"
    palette.windowText: "white"

    readonly property int emcMenu:      0
    readonly property int emcManual:    1
    readonly property int emcAuto:      2
    readonly property int emcProgram:   3

    readonly property var statenames: [
        qsTr("MENU"),
        qsTr("MANUAL"),
        qsTr("EXECUTE"),
        qsTr("PROGRAM")
    ]

    Item {
        id: statemachine

        state: {
            if (emc.task.menu === true) return statenames[emcMenu]
            if (emc.task.estop === true) return statenames[emcManual]
            if (emc.task.mode === emcManual) return statenames[emcManual]
            if (emc.task.mode === emcAuto) return statenames[emcAuto]
            if (emc.task.mode === emcProgram) return statenames[emcProgram]
            return {}
        }

        states: [
            State {
                name: statenames[emcManual]
                PropertyChanges {
                    target: btn1
                    text: qsTr("SETTINGS")
                    onClicked: emc.set_menu(true)
                }
                PropertyChanges {
                    target: btn2
                    text: qsTr("COMMAND")
                    onClicked: emc.set_menu(true)
                }
                PropertyChanges {
                    target: btn3
                    enabled: !emc.task.estop
                    text: qsTr("PROGRAM")
                    onClicked: emc.set_mode(emcProgram)
                }
                PropertyChanges {
                    target: btn4
                    enabled: !emc.task.estop
                    text: qsTr("EXECUTE")
                    onClicked: emc.set_mode(emcAuto)
                }
            },
            State {
                name: statenames[emcAuto]
                PropertyChanges {
                    target: btn1
                    text: qsTr("HOME")
                    onClicked: emc.set_mode(emcManual)
                }
                PropertyChanges {
                    target: btn2
                    text: qsTr("START")
                }
                PropertyChanges {
                    target: btn3
                    text: qsTr("FORWARD")
                }
                PropertyChanges {
                    target: btn4
                    text: qsTr("PAUSE")
                }
            },
            State {
                name: statenames[emcProgram]
                PropertyChanges {
                    target: btn1
                    text: qsTr("HOME")
                    onClicked: emc.set_mode(emcManual)
                }
                PropertyChanges {
                    target: btn2
                    text: qsTr("FILE")
                    onClicked: emc.set_menu(true)
                }
                PropertyChanges {
                    target: btn3
                    text: qsTr("MDI")
                }
                PropertyChanges {
                    target: btn4
                    text: qsTr("TEACH")
                }
            },
            State {
                name: statenames[emcMenu]
                PropertyChanges {
                    target: btn1
                    text: qsTr("BACK")
                    onClicked: emc.set_menu(false)
                }
                PropertyChanges {
                    target: btn2
                    text: qsTr("<<")
                }
                PropertyChanges {
                    target: btn3
                    text: qsTr(">>")
                }
                PropertyChanges {
                    target: btn4
                    text: qsTr("OK")
                }
            }
        ]
    }

    component CommandButton : RoundButton {
        font.pointSize: 12
        radius: 8
        Layout.fillWidth: true
        Layout.preferredWidth: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        RowLayout {

            Label {
                Layout.fillWidth: true
                font.pointSize: 24
                leftPadding: 32

                background: Rectangle {
                    color: "gray"
                    radius: 3
                }

                text: emc.info.machine + " v." + emc.info.version
            }

            Label {
                horizontalAlignment: Label.AlignHCenter
                Layout.preferredWidth: 256
                font.pointSize: 24

                background: Rectangle {
                    color: "gray"
                    radius: 3
                }

                text: statemachine.state
            }

            Label {
                horizontalAlignment: Label.AlignHCenter
                Layout.preferredWidth: 128
                font.pointSize: 24

                background: Rectangle {
                    color: emc.task.power ? "green" : "gray"
                    radius: 3
                }

                text: qsTr("POWER")
            }

            Label {
                horizontalAlignment: Label.AlignHCenter
                Layout.preferredWidth: 128
                font.pointSize: 24

                background: Rectangle {
                    color: emc.task.estop ? "red" : "gray"
                    radius: 3
                }

                text: qsTr("E-STOP")
            }

        }

        RowLayout {

            ScrollView {
                clip: true

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                topPadding: 32
                bottomPadding: 100
                contentWidth: width

                background: Rectangle {
                    color: "gray"
                    radius: 3
                }

                GridLayout {
                    columns: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 64

                    CommandButton {
                        text: qsTr("ESTOP ON/OFF")

                        onClicked: emc.set_estop(!emc.task.estop)
                    }

                    CommandButton {
                        text: qsTr("POWER ON/OFF")

                        enabled: !emc.task.estop
                        onClicked: emc.set_power(!emc.task.power)
                    }

                    CommandButton {
                        text: qsTr("JOG X FORWARD")

                        enabled: emc.task.power
                        onPressed: emc.jog(0, +100)
                        onReleased: emc.jog_stop(0)
                        onCanceled: emc.jog_stop(0)
                    }

                    CommandButton {
                        text: qsTr("JOG X BACKWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(0, -100)
                        onReleased: emc.jog_stop(0)
                        onCanceled: emc.jog_stop(0)
                    }

                    CommandButton {
                        text: qsTr("JOG Y FORWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(1, +100)
                        onReleased: emc.jog_stop(1)
                        onCanceled: emc.jog_stop(1)
                    }

                    CommandButton {
                        text: qsTr("JOG Y BACKWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(1, -100)
                        onReleased: emc.jog_stop(1)
                        onCanceled: emc.jog_stop(1)
                    }

                    CommandButton {
                        text: qsTr("JOG Z FORWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(2, +100)
                        onReleased: emc.jog_stop(2)
                        onCanceled: emc.jog_stop(2)
                    }

                    CommandButton {
                        text: qsTr("JOG Z BACKWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(2, -100)
                        onReleased: emc.jog_stop(2)
                        onCanceled: emc.jog_stop(2)
                    }

                    CommandButton {
                        text: qsTr("JOG A FORWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(3, +100)
                        onReleased: emc.jog_stop(3)
                        onCanceled: emc.jog_stop(3)
                    }

                    CommandButton {
                        text: qsTr("JOG A BACKWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(3, -100)
                        onReleased: emc.jog_stop(3)
                        onCanceled: emc.jog_stop(3)
                    }

                    CommandButton {
                        text: qsTr("JOG B FORWARD")
                        Layout.fillWidth: true

                        font.pointSize: 12
                        radius: 8

                        enabled: emc.task.power

                        onPressed: emc.jog(4, +100)
                        onReleased: emc.jog_stop(4)
                        onCanceled: emc.jog_stop(4)
                    }

                    CommandButton {
                        text: qsTr("JOG B BACKWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(4, -100)
                        onReleased: emc.jog_stop(4)
                        onCanceled: emc.jog_stop(4)
                    }

                    CommandButton {
                        text: qsTr("JOG C FORWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(5, +100)
                        onReleased: emc.jog_stop(5)
                        onCanceled: emc.jog_stop(5)
                    }

                    CommandButton {
                        text: qsTr("JOG C BACKWARD")

                        enabled: emc.task.power

                        onPressed: emc.jog(5, -100)
                        onReleased: emc.jog_stop(5)
                        onCanceled: emc.jog_stop(5)
                    }
                }
            }

            Label {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                background: Rectangle {
                    color: "gray"
                    radius: 3
                }

                TextEdit {
                    font.pointSize: 14
                    font.family: "monospace"
                    wrapMode: TextEdit.Wrap
                    color: "white"

                    anchors.fill: parent
                    text: "G00 X9000.00 Y2222.88 Z6500.77 A121.11 333.66 C990.09"
                }

                InputPanel {
                    y: parent.height - height
                    width: parent.width
                    visible: active
                }
            }

            Label {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                font.pointSize: 32
                font.family: "monospace"

                background: Rectangle {
                    color: "gray"
                    radius: 3
                }

                GridLayout {
                    columns: 1
                    anchors.fill: parent
                    anchors.margins: 100

                    Label { text: `X: ${emc.joint(0).position.toFixed(2)}` }
                    Label { text: `Y: ${emc.joint(1).position.toFixed(2)}` }
                    Label { text: `Z: ${emc.joint(2).position.toFixed(2)}` }
                    Label { text: `A: ${emc.joint(3).position.toFixed(2)}` }
                    Label { text: `B: ${emc.joint(4).position.toFixed(2)}` }
                    Label { text: `C: ${emc.joint(5).position.toFixed(2)}` }
                }
            }

        }

        RowLayout {

            CommandButton { text: qsTr("LinuxCNC v2.9") }
            CommandButton { id: btn1 }
            CommandButton { id: btn2 }
            CommandButton { id: btn3 }
            CommandButton { id: btn4 }

        }
    }
}
