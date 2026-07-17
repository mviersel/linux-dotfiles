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
    property int pendingVolumeDelta: 0

    function batteryLabel(): string {
        if (!batteryDevice.ready || !batteryDevice.isLaptopBattery) return "";

        return `${Math.round(batteryDevice.percentage)}%`;
    }

    function adjustVolume(delta: int): void {
        if (delta === 0) return;

        if (volumeAdjuster.running) {
            pendingVolumeDelta += delta;
            return;
        }

        const step = Math.max(1, Math.round(Math.abs(delta) / 120)) * 5;
        volumeAdjuster.command = ["sh", "-c", `wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ ${step}%${delta > 0 ? "+" : "-"} && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ if ($3 == "[MUTED]") { muted=1 } vol=int($2 * 100 + 0.5) } END { if (muted) printf "\\uf026 muted"; else printf "\\uf028 %d%%", vol }'`];
        volumeAdjuster.running = true;
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
                    color: activeWorkspace ? shell.accent : shell.bgHover
                    border.width: activeWorkspace ? 2 : 1
                    border.color: activeWorkspace ? shell.fg : shell.tooltipBorder
                    implicitHeight: 24
                    implicitWidth: Math.max(workspaceLabel.implicitWidth + (activeWorkspace ? 24 : 16), implicitHeight)

                    Label {
                        id: workspaceLabel

                        anchors.centerIn: parent
                        text: modelData.id > 0 ? `${modelData.id}` : modelData.name
                        color: activeWorkspace ? shell.bg : shell.fg
                        font.pixelSize: activeWorkspace ? 12 : 11
                        font.weight: activeWorkspace ? Font.Bold : Font.Medium
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
            mouseArea.onWheel: wheel => {
                barRoot.adjustVolume(wheel.angleDelta.y);
                wheel.accepted = true;
            }
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
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton || modelData.onlyMenu) {
                                const position = barRoot.QSWindow.mapFromItem(parent, parent.width / 2, parent.height);
                                modelData.display(barRoot.QSWindow.window, position.x, position.y);
                                return;
                            }

                            modelData.activate();
                        }
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

    Process {
        id: volumeAdjuster

        stdout: StdioCollector {
            onStreamFinished: {
                const volume = text.trim();
                if (volume) shell.volumeText = volume;

                if (pendingVolumeDelta !== 0) {
                    const delta = pendingVolumeDelta;
                    pendingVolumeDelta = 0;
                    adjustVolume(delta);
                }
            }
        }
    }
}
