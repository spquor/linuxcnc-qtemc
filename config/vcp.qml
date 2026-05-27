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

    readonly property int menuEdit:     0
    readonly property int menuConfig:   1
    readonly property int menuCommand:  2
    readonly property int menuFile:     3

    readonly property var statenames: [
        qsTr("MENU"),
        qsTr("JOG"),
        qsTr("AUTO"),
        qsTr("PROG")
    ]

    component IndicationLabel : Label {
        font.pointSize: 30
        background: Rectangle {
            color: "gray"
            radius: 3
        }
        horizontalAlignment: Label.AlignHCenter
        verticalAlignment: Label.AlignVCenter
        Layout.preferredWidth: 164
        Layout.preferredHeight: 64
    }

    component ScrollableMenu : ScrollView {
        clip: true
        contentWidth: width
        topPadding: 32
        bottomPadding: 100
        background: Rectangle {
            color: "gray"
            radius: 3
        }
        default property alias __gridLayout: innerLayout.children
        GridLayout {
            id: innerLayout
            columns: 1
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 64
        }
    }

    component CommandButton : RoundButton {
        font.pointSize: 20
        radius: 8
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.preferredWidth: 1
        Layout.preferredHeight: 64
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        // transform: Scale {
        //     xScale: 0.5
        //     yScale: 0.5
        // }

        RowLayout {

            IndicationLabel {
                horizontalAlignment: Label.AlignLeft
                leftPadding: 32
                Layout.fillWidth: true
                text: emc.info.machine + " v." + emc.info.version
            }

            IndicationLabel {
                text: statemachine.state
            }

            IndicationLabel {
                background: Rectangle {
                    color: emc.task.power ? "green" : "gray"
                    radius: 3
                }
                text: qsTr("POWER")
            }

            IndicationLabel {
                background: Rectangle {
                    color: emc.task.estop ? "red" : "gray"
                    radius: 3
                }
                text: qsTr("E-STOP")
            }

        }

        RowLayout {

            StackLayout {
                id: menuLayout
                currentIndex: 0

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1

                Label {
                    background: Rectangle {
                        color: "gray"
                        radius: 3
                    }

                    TextEdit {
                        font.pointSize: 20
                        font.family: "monospace"
                        wrapMode: TextEdit.Wrap
                        color: "white"

                        readOnly: emc.task.mode !== emcProgram

                        anchors.fill: parent
                        text: "G00 X9000.00 Y2222.88 Z6500.77 A121.11 B333.66 C990.09"
                    }

                    InputPanel {
                        y: parent.height - height
                        width: parent.width
                        visible: active
                    }
                }

                ScrollableMenu {

                    CommandButton {
                        text: qsTr("TEACH G COMMAND")
                    }

                    CommandButton {
                        text: qsTr("JOG MAX SPEED")
                    }

                    CommandButton {
                        text: qsTr("SPINDLE MAX SPEED")
                    }

                    CommandButton {
                        text: qsTr("FEED OVERRIDE")
                    }

                    CommandButton {
                        text: qsTr("RAPID OVERRIDE")
                    }

                    CommandButton {
                        text: qsTr("JOYSTICK CONTROL")
                    }
                }

                ScrollableMenu {

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

                ScrollableMenu {

                    CommandButton {
                        text: qsTr("INSPECT")
                    }

                    CommandButton {
                        text: qsTr("SAVE")
                    }

                    CommandButton {
                        text: qsTr("LOAD")
                    }

                    CommandButton {
                        text: qsTr("DELETE")
                    }
                }

            }

            Label {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                font.pointSize: 40
                font.family: "monospace"
                background: Rectangle {
                    color: "gray"
                    radius: 3
                }

                GridLayout {
                    columns: 1
                    anchors.fill: parent
                    anchors.margins: 64

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

            id: statemachine

            state: {
                if (emc.task.menu   === true)       return statenames[emcMenu]
                if (emc.task.estop  === true)       return statenames[emcManual]
                if (emc.task.mode   === emcManual)  return statenames[emcManual]
                if (emc.task.mode   === emcAuto)    return statenames[emcAuto]
                if (emc.task.mode   === emcProgram) return statenames[emcProgram]
                return null
            }

            states: [
                State {
                    name: statenames[emcManual]
                    PropertyChanges {
                        target: btn1
                        text: qsTr("SETTINGS")
                        onClicked: {
                            emc.set_menu(true)
                            menuLayout.currentIndex = menuConfig
                        }
                    }
                    PropertyChanges {
                        target: btn2
                        text: qsTr("COMMAND")
                        onClicked: {
                            emc.set_menu(true)
                            menuLayout.currentIndex = menuCommand
                        }
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
                        text: qsTr("BACK")
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
                        text: qsTr("BACK")
                        onClicked: emc.set_mode(emcManual)
                    }
                    PropertyChanges {
                        target: btn2
                        text: qsTr("FILE")
                        onClicked: {
                            emc.set_menu(true)
                            menuLayout.currentIndex = menuFile
                        }
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
                        onClicked: {
                            emc.set_menu(false)
                            menuLayout.currentIndex = 0
                        }
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
                        text: qsTr("SELECT")
                    }
                }
            ]

            CommandButton { text: qsTr("LinuxCNC v2.9") }
            CommandButton { id: btn1 }
            CommandButton { id: btn2 }
            CommandButton { id: btn3 }
            CommandButton { id: btn4 }

        }
    }
}
