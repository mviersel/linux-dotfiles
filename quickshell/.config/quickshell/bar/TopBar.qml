import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Widgets

Rectangle {
    id: barRoot

    required property var shell
    required property var barScreen

    readonly property var batteryDevice: UPower.displayDevice
    readonly property var barMonitor: Hyprland.monitorFor(barScreen)

    function batteryLabel(): string {
        if (!batteryDevice.ready || !batteryDevice.isLaptopBattery) return "";

        return `${Math.round(batteryDevice.percentage)}%`;
    }

    color: shell.bg
    radius: 10
    border.width: 1
    border.color: shell.tooltipBorder

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            Repeater {
                model: Hyprland.workspaces

                delegate: Rectangle {
                    required property var modelData

                    readonly property bool onCurrentMonitor: modelData.monitor === barRoot.barMonitor
                    readonly property bool activeWorkspace: modelData.focused || modelData.active

                    visible: onCurrentMonitor
                    radius: 6
                    color: activeWorkspace ? shell.accentSoft : shell.bgHover
                    border.width: 1
                    border.color: activeWorkspace ? shell.accentLine : shell.tooltipBorder
                    implicitHeight: 24
                    implicitWidth: Math.max(workspaceLabel.implicitWidth + 16, implicitHeight)

                    Label {
                        id: workspaceLabel

                        anchors.centerIn: parent
                        text: modelData.id > 0 ? `${modelData.id}` : modelData.name
                        color: activeWorkspace ? shell.accent : shell.fg
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.activate()
                    }
                }
            }

            StatusChip {
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: 320
                text: shell.activeWindowTitle
                bgColor: shell.bgHover
                fgColor: shell.fg
                borderColor: shell.tooltipBorder
            }
        }

        Item {
            Layout.fillWidth: true
        }

        MediaChip {
            Layout.alignment: Qt.AlignVCenter
            visible: true
            rootShell: barRoot.shell
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            text: shell.cpuUsageText
            bgColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.tooltipBorder
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            text: shell.volumeText
            bgColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.tooltipBorder
            clickable: true
            mouseArea.onClicked: volumeLauncher.startDetached()
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            text: "\uf293"
            bgColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.tooltipBorder
            clickable: true
            mouseArea.onClicked: bluetoothLauncher.startDetached()
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            text: Qt.formatDateTime(shell.shellClock.date, "ddd dd MMM  hh:mm")
            bgColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.tooltipBorder
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            visible: batteryDevice.ready && batteryDevice.isLaptopBattery
            text: `BAT ${batteryLabel()}`
            bgColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.tooltipBorder
        }

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            Repeater {
                model: SystemTray.items

                delegate: Rectangle {
                    required property var modelData

                    radius: 6
                    color: trayMouseArea.containsMouse ? shell.bgHover : shell.bg
                    border.width: 1
                    border.color: shell.tooltipBorder
                    implicitHeight: 24
                    implicitWidth: implicitHeight
                    visible: modelData.status !== 0

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 14
                        source: modelData.icon
                        asynchronous: true
                    }

                    MouseArea {
                        id: trayMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }

        StatusChip {
            id: powerChip

            Layout.alignment: Qt.AlignVCenter
            text: "\uf303"
            bgColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.tooltipBorder
            clickable: true
            mouseArea.onClicked: powerMenu.visible = !powerMenu.visible
        }
    }

    PanelWindow {
        visible: powerMenu.visible
        screen: barScreen
        color: "transparent"
        implicitWidth: screen ? screen.width : 0
        implicitHeight: screen ? screen.height : 0
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: powerMenu.visible = false
        }
    }

    PowerMenu {
        id: powerMenu

        rootShell: barRoot.shell
        anchorItem: powerChip
    }

    Process {
        id: bluetoothLauncher

        command: ["blueman-manager"]
    }

    Process {
        id: volumeLauncher

        command: ["pavucontrol"]
    }
}
