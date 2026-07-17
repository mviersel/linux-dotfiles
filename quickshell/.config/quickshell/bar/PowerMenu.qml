import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: popup

    required property var rootShell
    required property var anchorItem

    function runCommand(commandArgs: var): void {
        commandRunner.command = commandArgs;
        commandRunner.startDetached();
        visible = false;
    }

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Top | Edges.Right
    anchor.margins.top: 8
    visible: false
    color: "transparent"
    implicitWidth: 184
    implicitHeight: menuCard.implicitHeight

    Rectangle {
        id: menuCard

        anchors.fill: parent
        radius: 8
        color: rootShell.bg
        border.width: 1
        border.color: rootShell.tooltipBorder
        implicitHeight: menuColumn.implicitHeight + 16

        ColumnLayout {
            id: menuColumn

            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            Repeater {
                model: [
                    { label: "Lock", command: ["hyprlock"] },
                    { label: "Suspend", command: ["loginctl", "suspend"] },
                    { label: "Logout", command: ["sh", "-c", "loginctl terminate-user \"$USER\""] },
                    { label: "Restart", command: ["loginctl", "reboot"] },
                    { label: "Shutdown", command: ["loginctl", "poweroff"] }
                ]

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 6
                    color: powerMouse.containsMouse ? rootShell.bgHover : rootShell.bg
                    border.width: 1
                    border.color: rootShell.tooltipBorder

                    Label {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: rootShell.fg
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: powerMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.runCommand(modelData.command)
                    }
                }
            }
        }
    }

    Process {
        id: commandRunner
    }
}
