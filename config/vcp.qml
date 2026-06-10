import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtQuick.VirtualKeyboard 2.15
import Qt.labs.folderlistmodel 2.12

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

    Popup {
        id: popupScreen
        anchors.centerIn: parent
        modal: true
        width: 640
        background: Rectangle {
            color: "black"
            radius: 8
        }
        ColumnLayout {
            anchors.fill: parent
            Text {
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
                font.pointSize: 30
                color: emc.info.msgtype === emc.enums.msgError ? "red" : "white"
                text: emc.info.msgtype === emc.enums.msgError ? qsTr("ERROR") : qsTr("INFO")
            }
            Text {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pointSize: 20
                color: "white"
                text: emc.info.msg.join("\n")
            }
        }
        onClosed: emc.msg_reset()
        visible: emc.info.msg.length > 0
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

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
                    color: emc.task.stat == emc.enums.statusError ? "red" : "gray"
                    radius: 3
                }
                text: statusnames[emc.task.stat] ?? null
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

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                ColumnLayout {

                    TextArea {
                        font.pointSize: 20
                        font.family: "monospace"
                        wrapMode: TextEdit.Wrap
                        color: "white"

                        enabled: false
                        readOnly: true

                        Layout.preferredHeight: padding + 100
                        Layout.fillWidth: true

                        background: Rectangle {
                            color: "gray"
                            radius: 3
                        }

                        text: emc.prog.mcodes.join(" ") + " " + emc.prog.gcodes.join(" ")
                    }

                    TextArea {
                        font.pointSize: 20
                        font.family: "monospace"
                        wrapMode: TextEdit.Wrap
                        color: "white"

                        readOnly: emc.task.mode !== emc.enums.stateProgram
                        readonly property double lineHeight: contentHeight / lineCount

                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        background: Rectangle {
                            color: "gray"
                            radius: 3
                        }

                        Rectangle {
                            visible: emc.prog.linenum > 0
                            color: "lightyellow"
                            opacity: 0.5
                            y: parent.padding + (emc.prog.linenum - 1) * parent.lineHeight
                            width: parent.width
                            height: parent.lineHeight
                        }

                        Rectangle {
                            visible: !parent.readOnly
                            color: "lightyellow"
                            opacity: 0.5
                            y: parent.cursorRectangle.y
                            width: parent.width
                            height: parent.lineHeight
                        }

                        id: programEditor

                        onEditingFinished: {
                            emc.task_init()
                            emc.prog_save(emc.prog.name, text)
                            emc.prog_open(emc.prog.name)
                        }

                        text: emc.prog.text
                    }

                    InputPanel {
                        y: parent.height - height
                        width: parent.width
                        visible: active
                    }
                }

                ScrollableMenu {

                    Label {
                        text: qsTr("MODE SELECT")
                        font.pointSize: 20
                        Layout.alignment: Qt.AlignHCenter
                    }

                    CommandButton {
                        text: qsTr("MANUAL JOG")
                        highlighted: emc.task.mode === emc.enums.stateManual
                        onClicked: emc.set_mode(emc.enums.stateManual)
                    }

                    CommandButton {
                        text: qsTr("PROGRAMMING")
                        highlighted: emc.task.mode === emc.enums.stateProgram
                        onClicked: emc.set_mode(emc.enums.stateProgram)
                    }

                    CommandButton {
                        text: qsTr("AUTO CYCLE")
                        highlighted: emc.task.mode === emc.enums.stateAuto
                        onClicked: emc.set_mode(emc.enums.stateAuto)
                    }

                    Label { Layout.preferredHeight: 16 }

                    Label {
                        text: qsTr("JOG MAX SPEED:") + ` ${jogMaxSpeed.value.toFixed(0)}`
                        font.pointSize: 20
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Slider {
                        id: jogMaxSpeed
                        to: emc.info.maxjogspd
                        value: emc.info.initjogspd
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("FEED OVERRIDE:") + ` ${emc.task.feed.toFixed(0)} `
                        font.pointSize: 20
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Slider {
                        onValueChanged: emc.override_feed(value)
                        to: emc.info.maxfeed
                        value: emc.info.initfeed
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("RAPID OVERRIDE:") + ` ${emc.task.rapid.toFixed(0)} `
                        font.pointSize: 20
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Slider {
                        onValueChanged: emc.override_rapid(value)
                        to: emc.info.maxrapid
                        value: emc.info.initrapid
                        Layout.fillWidth: true
                    }

                }

                ScrollableMenu {

                    Label {
                        text: qsTr("MACHINE CONTROL")
                        font.pointSize: 20
                        Layout.alignment: Qt.AlignHCenter
                    }

                    CommandButton {
                        text: qsTr("UNLOCK JOINTS")
                        enabled: !emc.task.estop && emc.task.traj > 1
                        onClicked: emc.unlock_joints()
                    }

                    Label {
                        text: "\n" + qsTr("AXIS") + ` [ ${emc.info.axes[currentAxis]} ] ` + qsTr("CONTROL")
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
                        onPressed: emc.jog(currentAxis, +jogMaxSpeed.value.toFixed(0))
                        onReleased: emc.jog_stop(currentAxis)
                        onCanceled: emc.jog_stop(currentAxis)
                    }

                    CommandButton {
                        text: qsTr("JOG BACKWARD")
                        enabled: emc.task.power
                        onPressed: emc.jog(currentAxis, -jogMaxSpeed.value.toFixed(0))
                        onReleased: emc.jog_stop(currentAxis)
                        onCanceled: emc.jog_stop(currentAxis)
                    }

                }

                ScrollableMenu {

                    CommandButton {
                        text: qsTr("SAVE")
                        onClicked: {
                            var firstLine = programEditor.text.split("\n")[0]
                            var nameRegex = /^[oO](\d{1,4})/
                            var matchResult = firstLine.match(nameRegex);

                            if (matchResult !== null) {
                                 emc.prog_save(`./ngc/o${matchResult[1]}.ngc`, programEditor.text)
                                 emc.msg_set(qsTr("Program saved to file:") + ` o${matchResult[1]}.ngc `, emc.enums.msgOpText)
                            } else {
                                 emc.msg_set(qsTr("Program should start with a number (e.g. o1000)"), emc.enums.msgError)
                            }
                        }
                    }

                    CommandButton {
                        text: qsTr("OPEN")
                        highlighted: openSubmenu.isActive
                        onClicked: openSubmenu.isActive = !openSubmenu.isActive
                    }

                    Repeater {
                        id: openSubmenu
                        property bool isActive: false

                        model: FolderListModel {
                            folder: "./ngc/"
                            nameFilters: ["*.nc", "*.ngc"]
                        }

                        CommandButton {
                            text: fileName
                            visible: openSubmenu.isActive
                            onClicked: {
                                emc.task_init()
                                emc.prog_save(emc.prog.name, emc.prog_read(filePath))
                                emc.prog_open(emc.prog.name)
                                emc.msg_set(qsTr("Opened new program:") + ` ${fileName} `, emc.enums.msgOpText)
                            }
                        }
                    }

                    CommandButton {
                        text: qsTr("DELETE")
                        highlighted: deleteSubmenu.isActive
                        onClicked: deleteSubmenu.isActive = !deleteSubmenu.isActive
                    }

                    Repeater {
                        id: deleteSubmenu
                        property bool isActive: false

                        model: FolderListModel {
                            folder: "./ngc/"
                            nameFilters: ["*.nc", "*.ngc"]
                        }

                        CommandButton {
                            text: fileName
                            visible: deleteSubmenu.isActive
                            onClicked: {
                                if (emc.prog_remove(filePath))
                                    emc.msg_set(qsTr("Program removed:") + ` ${fileName} `, emc.enums.msgOpText)
                            }
                        }
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
                        enabled: emc.task.power
                        onClicked: {
                            emc.set_menu(true)
                            menuLayout.currentIndex = emc.enums.menuCommand
                        }
                    }
                    PropertyChanges {
                        target: btn3
                        text: qsTr("POWER")
                        enabled: !emc.task.estop
                        onClicked: {
                            onClicked: emc.set_power(!emc.task.power)
                        }
                    }
                    PropertyChanges {
                        target: btn4
                        text: qsTr("ESTOP")
                        onClicked: {
                            onClicked: emc.set_estop(!emc.task.estop)
                        }
                    }
                },
                State {
                    name: statenames[emc.enums.stateAuto]
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
                        text: !emc.prog.suspend ? qsTr("PAUSE") : qsTr("RESUME")
                        onClicked: !emc.prog.suspend ? emc.prog_pause() : emc.prog_resume()
                    }
                },
                State {
                    name: statenames[emc.enums.stateProgram]
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
                        text: qsTr("FILE")
                        onClicked: {
                            emc.set_menu(true)
                            menuLayout.currentIndex = emc.enums.menuFile
                        }
                    }
                    PropertyChanges {
                        target: btn3
                        text: qsTr("VERIFY")
                        onClicked: {
                            emc.set_mode(emc.enums.stateAuto)
                            emc.prog_start(-1)
                        }
                    }
                    PropertyChanges {
                        target: btn4
                        text: qsTr("EDIT")
                        highlighted: programEditor.focus
                        onClicked: programEditor.focus = !programEditor.focus
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
                        onClicked: io.postFocusPrev()
                    }
                    PropertyChanges {
                        target: btn3
                        text: qsTr(">>")
                        onClicked: io.postFocusNext()
                    }
                    PropertyChanges {
                        target: btn4
                        text: qsTr("SELECT")
                        onPressed: io.postItemActivate()
                        onReleased: io.postItemRelease()
                        onCanceled: io.postItemRelease()
                    }
                }
            ]

            Connections {
                target: io
                function onSig_estop(isDown) {
                    emc.set_estop(isDown)
                }
                function onSig_move(isDown) {
                    if (isDown && !emc.task.power && !emc.task.estop)
                        emc.set_power(true)
                }
                function onSig_button1(isDown) {
                    if (isDown) { btn1.onPressed(); }
                    else { btn1.onReleased(); btn1.onClicked(); }
                    btn1.down = { isDown }
                }
                function onSig_button2(isDown) {
                    if (isDown) { btn2.onPressed(); }
                    else { btn2.onReleased(); btn2.onClicked(); }
                    btn2.down = { isDown }
                }
                function onSig_button3(isDown) {
                    if (isDown) { btn3.onPressed(); }
                    else { btn3.onReleased(); btn3.onClicked(); }
                    btn3.down = { isDown }
                }
                function onSig_button4(isDown) {
                    if (isDown) { btn4.onPressed(); }
                    else { btn4.onReleased(); btn4.onClicked(); }
                    btn4.down = { isDown }
                }
                function onSig_joystick(x, y, z) {
                    if (emc.task.power)
                        console.log(x, y, z);
                }
            }

            CommandButton {
                text: qsTr("LinuxCNC v2.9")
                focusPolicy: Qt.NoFocus
                onClicked: emc.msg_set(qsTr("LinuxCNC controls CNC machines. It can drive milling machines, lathes," +
                    "3D printers, laser cutters, plasma cutters, robot arms, hexapods, and more."), emc.enums.msgAbout)
            }
            CommandButton {
                id: btn1
                focusPolicy: Qt.NoFocus
            }
            CommandButton {
                id: btn2
                focusPolicy: Qt.NoFocus
            }
            CommandButton {
                id: btn3
                focusPolicy: Qt.NoFocus
            }
            CommandButton {
                id: btn4
                focusPolicy: Qt.NoFocus
            }

        }
    }
}
