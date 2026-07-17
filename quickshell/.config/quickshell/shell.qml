import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import "bar" as Bar

ShellRoot {
    id: root

    readonly property color bg: "#12130d"
    readonly property color bgHover: "#2a2d1c"
    readonly property color fg: "#dbe3c6"
    readonly property color fgMuted: "#8e9963"
    readonly property color accent: "#b9c97a"
    readonly property color accentSoft: "#1fb9c97a"
    readonly property color accentLine: "#3db9c97a"
    readonly property color tooltipBorder: "#1fdbe3c6"
    readonly property color shadow: "#33000000"
    readonly property alias shellClock: clock
    property string activeWindowTitle: "Desktop"
    property string cpuUsageText: "\uf2db --%"
    property string volumeText: "\uf028 --%"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: if (!cpuProcess.running) cpuProcess.running = true
    }

    Process {
        id: cpuProcess

        command: ["sh", "-c", "read cpu u n s i w irq sirq st g gn < /proc/stat; total1=$((u+n+s+i+w+irq+sirq+st)); idle1=$((i+w)); sleep 0.2; read cpu u n s i w irq sirq st g gn < /proc/stat; total2=$((u+n+s+i+w+irq+sirq+st)); idle2=$((i+w)); diff_total=$((total2-total1)); diff_idle=$((idle2-idle1)); if [ \"$diff_total\" -gt 0 ]; then printf '%s\n' $((100*(diff_total-diff_idle)/diff_total)); else printf '0\n'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const usage = text.trim();
                root.cpuUsageText = `\uf2db ${usage || "--"}%`;
            }
        }
    }

    Process {
        id: activeWindowProcess

        command: ["sh", "-c", "hyprctl activewindow | awk -F': ' '/^\tclass: /{print $2; found=1; exit} /^class: /{print $2; found=1; exit} /^\tinitialClass: /{print $2; found=1; exit} /^initialClass: /{print $2; found=1; exit} END{if (!found) print \"Desktop\"}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const title = text.trim();
                root.activeWindowTitle = title || "Desktop";
            }
        }
    }

    Component.onCompleted: activeWindowProcess.running = true

    Connections {
        target: Hyprland

        function onRawEvent() {
            if (!activeWindowProcess.running) activeWindowProcess.running = true;
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: if (!volumeProcess.running) volumeProcess.running = true
    }

    Process {
        id: volumeProcess

        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ if ($3 == \"[MUTED]\") { muted=1 } vol=int($2 * 100 + 0.5) } END { if (muted) printf \"\\uf026 muted\"; else printf \"\\uf028 %d%%\", vol }'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const volume = text.trim();
                root.volumeText = volume || "\uf028 --%";
            }
        }
    }

    property var popupScreen: {
        for (const screen of Quickshell.screens) {
            if (screen.name === "DP-2") return screen;
        }

        return Quickshell.screens.length ? Quickshell.screens[0] : null;
    }

    function activePlayer() {
        const players = Mpris.players.values;

        for (const player of players) {
            if (player && player.isPlaying) return player;
        }

        return players.length ? players[0] : null;
    }

    function togglePopup(): void {
        if (!window.visible) {
            if (popupScreen) {
                window.screen = popupScreen;
            }

            window.visible = true;
            return;
        }

        window.visible = false;
    }

    Instantiator {
        model: Quickshell.screens

        delegate: PanelWindow {
            required property var modelData

            screen: modelData
            color: "transparent"
            aboveWindows: true
            exclusiveZone: 42
            implicitWidth: screen ? screen.width : 0
            implicitHeight: 42
            anchors {
                top: true
                left: true
                right: true
            }
            margins {
                left: 10
                right: 10
                top: 8
            }

            Bar.TopBar {
                anchors.fill: parent
                shell: root
                barScreen: modelData
            }
        }
    }

    PanelWindow {
        id: window

        property var currentPlayer: root.activePlayer()

        visible: false
        color: "transparent"
        focusable: true
        implicitWidth: screen ? screen.width : 0
        implicitHeight: screen ? screen.height : 0
        onVisibleChanged: if (visible) overlayFocus.forceActiveFocus()
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        FocusScope {
            id: overlayFocus
            anchors.fill: parent
            focus: window.visible

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    window.visible = false;
                    event.accepted = true;
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: window.visible = false
            }

            Rectangle {
                id: cardShadow
                anchors.horizontalCenter: card.horizontalCenter
                anchors.top: card.top
                anchors.topMargin: 2
                width: card.width
                height: card.height
                radius: card.radius
                color: root.shadow
            }

            Rectangle {
                id: card
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 32
                width: 408
                height: 156
                radius: 6
                color: root.bg
                border.width: 1
                border.color: root.tooltipBorder

                MouseArea {
                    anchors.fill: parent
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 112
                        Layout.preferredHeight: 112
                        Layout.alignment: Qt.AlignVCenter
                        radius: 6
                        color: root.bgHover
                        clip: true

                        Image {
                            id: artImage
                            anchors.fill: parent
                            source: window.currentPlayer && window.currentPlayer.trackArtUrl ? window.currentPlayer.trackArtUrl : ""
                            fillMode: Image.PreserveAspectCrop
                            visible: source !== ""
                            asynchronous: true
                            cache: true
                        }

                        Label {
                            anchors.centerIn: parent
                            text: "No Art"
                            color: root.fgMuted
                            visible: !artImage.visible
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: window.currentPlayer ? (window.currentPlayer.trackTitle || "Unknown Title") : "Nothing playing"
                                color: root.fg
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: window.currentPlayer ? (window.currentPlayer.trackArtist || "Unknown Artist") : "Open a media player with MPRIS support"
                                color: root.fgMuted
                                font.pixelSize: 13
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: window.currentPlayer ? window.currentPlayer.identity : ""
                                color: root.fgMuted
                                font.pixelSize: 11
                                visible: text !== ""
                                elide: Text.ElideRight
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Button {
                                Layout.fillWidth: true
                                text: "<<"
                                enabled: window.currentPlayer && window.currentPlayer.canGoPrevious
                                onClicked: window.currentPlayer.previous()
                                implicitHeight: 28

                                contentItem: Label {
                                    text: parent.text
                                    color: parent.enabled ? root.fg : root.fgMuted
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                }

                                background: Rectangle {
                                    radius: 6
                                    color: parent.down ? root.accentSoft : parent.hovered ? root.bgHover : root.bg
                                    border.width: 1
                                    border.color: parent.down ? root.accentLine : root.tooltipBorder
                                    opacity: parent.enabled ? 1 : 0.65
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                text: window.currentPlayer && window.currentPlayer.isPlaying ? "Pause" : "Play"
                                enabled: window.currentPlayer && window.currentPlayer.canTogglePlaying
                                onClicked: window.currentPlayer.togglePlaying()
                                implicitHeight: 28

                                contentItem: Label {
                                    text: parent.text
                                    color: parent.enabled ? root.accent : root.fgMuted
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                }

                                background: Rectangle {
                                    radius: 6
                                    color: parent.down ? root.bgHover : root.accentSoft
                                    border.width: 1
                                    border.color: root.accentLine
                                    opacity: parent.enabled ? 1 : 0.65
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                text: ">>"
                                enabled: window.currentPlayer && window.currentPlayer.canGoNext
                                onClicked: window.currentPlayer.next()
                                implicitHeight: 28

                                contentItem: Label {
                                    text: parent.text
                                    color: parent.enabled ? root.fg : root.fgMuted
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                }

                                background: Rectangle {
                                    radius: 6
                                    color: parent.down ? root.accentSoft : parent.hovered ? root.bgHover : root.bg
                                    border.width: 1
                                    border.color: parent.down ? root.accentLine : root.tooltipBorder
                                    opacity: parent.enabled ? 1 : 0.65
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "music"

        function toggle(): void {
            root.togglePopup();
        }
    }
}
