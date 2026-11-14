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
    readonly property var workspaceNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    property int pendingVolumeDelta: 0

    function workspaceForId(workspaceId: int): var {
        return Hyprland.workspaces.values.find(workspace => workspace.id === workspaceId) || null;
    }

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
    radius: 0
    border.width: 1
    border.color: shell.barBorder

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            StatusChip {
                id: powerChip

                Layout.alignment: Qt.AlignVCenter
                text: "\uf303"
                bgColor: shell.chipBg
                hoverColor: shell.bgHover
                fgColor: shell.fg
                borderColor: shell.barBorder
                clickable: true
                mouseArea.onClicked: powerMenu.visible = !powerMenu.visible
            }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 1

                Repeater {
                    model: barRoot.workspaceNumbers

                    delegate: Rectangle {
                        required property int modelData

                        readonly property int workspaceNumber: modelData
                        readonly property var workspace: barRoot.workspaceForId(workspaceNumber)
                        readonly property bool activeWorkspace: workspace ? workspace.focused : false

                        radius: 6
                        color: workspaceMouse.containsMouse ? shell.bgHover : "transparent"
                        border.width: 0
                        border.color: shell.barBorder
                        implicitHeight: 24
                        implicitWidth: implicitHeight

                        Label {
                            id: workspaceLabel

                            anchors.centerIn: parent
                            text: activeWorkspace ? "" : ""
                            color: activeWorkspace ? shell.accent : shell.fgMuted
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: workspaceMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch(`workspace ${workspaceNumber}`)
                        }
                    }
                }
            }

            StatusChip {
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: 320
                text: shell.activeWindowTitle
                bgColor: shell.chipBg
                fgColor: shell.fg
                borderColor: shell.barBorder
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
            bgColor: shell.chipBg
            fgColor: shell.fg
            borderColor: shell.barBorder
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            text: shell.volumeText
            bgColor: shell.chipBg
            hoverColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.barBorder
            clickable: true
            mouseArea.onClicked: volumeLauncher.startDetached()
            mouseArea.onWheel: wheel => {
                barRoot.adjustVolume(wheel.angleDelta.y);
                wheel.accepted = true;
            }
        }

        StatusChip {
            id: mixerChip

            Layout.alignment: Qt.AlignVCenter
            text: "\uf1de"
            bgColor: shell.chipBg
            hoverColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.barBorder
            clickable: true
            mouseArea.onClicked: mixerMenu.visible = !mixerMenu.visible
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            text: "\uf293"
            bgColor: shell.chipBg
            hoverColor: shell.bgHover
            fgColor: shell.fg
            borderColor: shell.barBorder
            clickable: true
            mouseArea.onClicked: bluetoothLauncher.startDetached()
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            text: Qt.formatDateTime(shell.shellClock.date, "ddd dd MMM  hh:mm")
            bgColor: shell.chipBg
            fgColor: shell.fg
            borderColor: shell.barBorder
        }

        StatusChip {
            Layout.alignment: Qt.AlignVCenter
            visible: batteryDevice.ready && batteryDevice.isLaptopBattery
            text: `BAT ${batteryLabel()}`
            bgColor: shell.chipBg
            fgColor: shell.fg
            borderColor: shell.barBorder
        }

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            Repeater {
                model: SystemTray.items

                delegate: Rectangle {
                    required property var modelData

                    radius: 0
                    color: trayMouseArea.containsMouse ? shell.bgHover : shell.chipBg
                    border.width: 1
                    border.color: shell.barBorder
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

    PanelWindow {
        id: mixerDismissWindow

        visible: mixerMenu.visible
        screen: barScreen
        color: "transparent"
        focusable: true
        implicitWidth: screen ? screen.width : 0
        implicitHeight: screen ? screen.height : 0
        onVisibleChanged: if (visible) mixerDismissFocus.forceActiveFocus()
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        FocusScope {
            id: mixerDismissFocus

            anchors.fill: parent
            focus: mixerDismissWindow.visible

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    mixerMenu.visible = false;
                    event.accepted = true;
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mixerMenu.visible = false
            }
        }
    }

    MixerMenu {
        id: mixerMenu

        rootShell: barRoot.shell
        anchorItem: mixerChip
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
