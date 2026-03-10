import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    title: emc.info.machine + " v." + emc.info.version

    visible: true
    width: 640
    height: 480

    Text {
        id: statusText

        anchors.centerIn: parent
        font.pointSize: 24

        text: "E-STOP: " + (emc.task.estop ? "ON" : "OFF") + "\t"
                + "POWER: " + (emc.task.power ? "ON" : "OFF")
    }

    Row {
        id: xJog
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: statusText.top
        anchors.bottomMargin: 10

        Text {
            id: xJogValue
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 24

            text: `X: ${emc.joint(0).position.toFixed(4)}`
        }

        Button {
            id: xHome

            text: "Home"
            enabled: emc.task.power && (emc.task.mode == 1)
            checkable: true
            checked: false

            onToggled: {
                if (checked) {
                    emc.set_home(0, true)
                    color: "lightblue"
                } else {
                    emc.set_home(0, false)
                    color: "lightgray"
                }
            }
        }

        Button {
            id: xJogBackwards

            text: "<"
            enabled: emc.task.power && (emc.task.mode == 1)

            onPressed: emc.jog(0, -100)
            onReleased: emc.jog_stop(0)
            onCanceled: emc.jog_stop(0)
        }

        Button {
            id: xJogForwards

            text: ">"
            enabled: emc.task.power && (emc.task.mode == 1)

            onPressed: emc.jog(0, +100)
            onReleased: emc.jog_stop(0)
            onCanceled: emc.jog_stop(0)
        }

    }

    Row {
        id: modeSelector

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: statusText.bottom
        anchors.topMargin: 10

        RadioButton {
            id: btnManual

            text: "MANUAL"
            checked: emc.task.mode == 1

            onClicked: emc.set_mode(1)
        }

        RadioButton {
            id: btnAuto

            text: "AUTO"
            checked: emc.task.mode == 2

            onClicked: emc.set_mode(2)
        }

        RadioButton {
            id: btnMdi

            text: "MDI"
            checked: emc.task.mode == 3

            onClicked: emc.set_mode(3)
        }
    }

    Button {
        id: estopButton

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: modeSelector.bottom
        anchors.topMargin: 20

        text: "Turn Estop"

        onClicked: emc.set_estop(!emc.task.estop)
    }

    Button {
        id: powerButton

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: estopButton.bottom
        anchors.topMargin: 20

        text: "Turn Machine"

        enabled: !emc.task.estop

        onClicked: emc.set_power(!emc.task.power)
    }
}
