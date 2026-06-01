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

    property int currentAxis: 0

    readonly property var statusnames: [
        qsTr("UNKNOWN"),
        qsTr("DONE"),
        qsTr("EXEC"),
        qsTr("ALARM")
    ]

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

    component CommandButton : RoundButton {
        font.pointSize: 20
        radius: 8
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.preferredWidth: 1
        Layout.preferredHeight: 64
    }

    component ScrollableMenu : ScrollView {
        clip: true
        contentWidth: width
        topPadding: 40
        bottomPadding: 120
        ScrollBar.vertical: ScrollBar {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            implicitWidth: 40
        }
        background: Rectangle {
            color: "gray"
            radius: 3
        }
        default property alias __gridLayout: innerLayout.children
        GridLayout {
            id: innerLayout
            columns: 1
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 120
        }
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
                background: Rectangle {
                    color: emc.task.stat == emc.enums.statusError ? "red" : "gray"
                    radius: 3
                }
                text: statusnames[emc.task.stat]
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

                        readOnly: emc.task.mode !== emc.enums.stateProgram

                        FontMetrics {
                            id: metrics
                        }

                        Rectangle {
                            visible: emc.prog.linenum > 0
                            z: -1
                            color: "lightyellow"
                            opacity: 0.5

                            x: parent.x
                            y: parent.y + (emc.prog.linenum - 1) * metrics.height * 2
                            width: parent.width
                            height: (metrics.height - 4) * 2
                        }

                        anchors.fill: parent
                        text: emc.prog.text
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

                    Label {
                        text: qsTr("MACHINE CONTROL")
                        font.pointSize: 20
                        Layout.alignment: Qt.AlignHCenter
                    }

                    CommandButton {
                        text: qsTr("ESTOP ON/OFF")
                        onClicked: emc.set_estop(!emc.task.estop)
                    }

                    CommandButton {
                        text: qsTr("POWER ON/OFF")
                        enabled: !emc.task.estop
                        onClicked: emc.set_power(!emc.task.power)
                    }

                    Label {
                        text: "\n" + qsTr("AXIS") + ` ${emc.info.axes[currentAxis]} ` + qsTr("CONTROL")
                        font.pointSize: 20
                        Layout.alignment: Qt.AlignHCenter
                    }

                    CommandButton {
                        text: qsTr("NEXT AXIS")
                        enabled: emc.task.power
                        onClicked: currentAxis = (currentAxis + 1) % emc.info.axes.length
                    }

                    CommandButton {
                        text: qsTr("HOME AXIS")
                        enabled: emc.task.power
                        onClicked: emc.set_home(currentAxis, true)
                    }

                    CommandButton {
                        text: qsTr("JOG FORWARD")
                        enabled: emc.task.power
                        onPressed: emc.jog(currentAxis, +10)
                        onReleased: emc.jog_stop(currentAxis)
                        onCanceled: emc.jog_stop(currentAxis)
                    }

                    CommandButton {
                        text: qsTr("JOG BACKWARD")
                        enabled: emc.task.power
                        onPressed: emc.jog(currentAxis, -10)
                        onReleased: emc.jog_stop(currentAxis)
                        onCanceled: emc.jog_stop(currentAxis)
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
                font.pointSize: 40
                font.family: "monospace"
                background: Rectangle {
                    color: "gray"
                    radius: 3
                }

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                GridLayout {
                    columns: 1
                    anchors.fill: parent
                    anchors.margins: 64

                    Repeater {
                        model: emc.info.jointnum

                        Label {
                            readonly property int i: index
                            color: emc.joint(i).homed ? "lightgreen" : "white"
                            text: `${emc.info.axes[i]}: ${emc.joint(i).position.toFixed(4)}`
                        }
                    }
                }
            }

        }

        RowLayout {

            id: statemachine

            state: {
                if (emc.task.menu === true)
                    return statenames[emc.enums.stateMenu]
                if (emc.task.estop === true)
                    return statenames[emc.enums.stateManual]
                if (emc.task.mode === emc.enums.stateManual)
                    return statenames[emc.enums.stateManual]
                if (emc.task.mode === emc.enums.stateAuto)
                    return statenames[emc.enums.stateAuto]
                if (emc.task.mode === emc.enums.stateProgram)
                    return statenames[emc.enums.stateProgram]
                return null
            }

            states: [
                State {
                    name: statenames[emc.enums.stateManual]
                    PropertyChanges {
                        target: btn1
                        text: qsTr("SETTINGS")
                        onClicked: {
                            emc.set_menu(true)
                            menuLayout.currentIndex = emc.enums.menuSettings
                        }
                    }
                    PropertyChanges {
                        target: btn2
                        text: qsTr("COMMAND")
                        onClicked: {
                            emc.set_menu(true)
                            menuLayout.currentIndex = emc.enums.menuCommand
                        }
                    }
                    PropertyChanges {
                        target: btn3
                        enabled: !emc.task.estop
                        text: qsTr("PROGRAM")
                        onClicked: emc.set_mode(emc.enums.stateProgram)
                    }
                    PropertyChanges {
                        target: btn4
                        enabled: !emc.task.estop
                        text: qsTr("EXECUTE")
                        onClicked: emc.set_mode(emc.enums.stateAuto)
                    }
                },
                State {
                    name: statenames[emc.enums.stateAuto]
                    PropertyChanges {
                        target: btn1
                        text: !emc.prog.suspend ? qsTr("BACK") : qsTr("RESUME")
                        onClicked: !emc.prog.suspend ? emc.set_mode(emc.enums.stateManual) : emc.prog_resume()
                    }
                    PropertyChanges {
                        target: btn2
                        text: !emc.prog.suspend ? qsTr("START") : qsTr("STEP")
                        onClicked: !emc.prog.suspend ? emc.prog_start() : emc.prog_step()
                    }
                    PropertyChanges {
                        target: btn3
                        text: qsTr("STOP")
                        onClicked: emc.task_abort()
                    }
                    PropertyChanges {
                        target: btn4
                        highlighted: emc.prog.suspend
                        text: qsTr("PAUSE")
                        onClicked: emc.prog_pause()
                    }
                },
                State {
                    name: statenames[emc.enums.stateProgram]
                    PropertyChanges {
                        target: btn1
                        text: qsTr("BACK")
                        onClicked: emc.set_mode(emc.enums.stateManual)
                    }
                    PropertyChanges {
                        target: btn2
                        text: qsTr("FILE")
                        onClicked: {
                            emc.set_menu(true)
                            menuLayout.currentIndex = emc.enums.menuFile
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
                    name: statenames[emc.enums.stateMenu]
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
