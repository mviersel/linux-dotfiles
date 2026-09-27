import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: popup

    required property var rootShell
    required property var anchorItem
    property var groups: []

    function matchesGroup(input: var, key: string): bool {
        const properties = input.properties || {};
        const name = `${properties["application.name"] || ""} ${properties["application.process.binary"] || ""} ${properties["media.name"] || ""}`.toLowerCase();

        if (key === "spotify") return /spotify/.test(name);
        if (key === "browser") return /(helium|zen|floorp|brave)/.test(name);
        if (key === "discord") return /discord/.test(name);

        return false;
    }

    function inputVolume(input: var): number {
        const channels = input.volume || {};
        const names = Object.keys(channels);
        if (!names.length) return 0;

        return Math.round(parseFloat(channels[names[0]].value_percent) || 0);
    }

    function makeGroup(key: string, label: string, inputs: var): var {
        const members = inputs.filter(input => matchesGroup(input, key));
        const volumes = members.map(input => inputVolume(input));
        const volume = volumes.length ? Math.round(volumes.reduce((sum, value) => sum + value, 0) / volumes.length) : 0;

        return {
            key: key,
            label: label,
            ids: members.map(input => input.index),
            volume: volume,
            muted: members.length > 0 && members.every(input => input.mute),
            available: members.length > 0
        };
    }

    function refresh(): void {
        if (!refreshProcess.running) refreshProcess.running = true;
    }

    function setGroupVolume(group: var, volume: real): void {
        const target = Math.max(0, Math.min(100, Math.round(volume)));
        const command = group.key === "main"
            ? `wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ ${target}%`
            : group.ids.map(id => `pactl set-sink-input-volume ${id} ${target}%`).join(" && ");

        if (!command) return;
        commandRunner.command = ["sh", "-c", `${command}; sleep 0.08`];
        commandRunner.running = true;
    }

    function setGroupMuted(group: var, muted: bool): void {
        const command = group.key === "main"
            ? `wpctl set-mute @DEFAULT_AUDIO_SINK@ ${muted ? 1 : 0}`
            : group.ids.map(id => `pactl set-sink-input-mute ${id} ${muted ? 1 : 0}`).join(" && ");

        if (!command) return;
        commandRunner.command = ["sh", "-c", `${command}; sleep 0.08`];
        commandRunner.running = true;
    }

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.bottom: 8
    visible: false
    color: "transparent"
    implicitWidth: 308
    implicitHeight: menuCard.implicitHeight
    onVisibleChanged: if (visible) refresh()

    Timer {
        interval: 1500
        repeat: true
        running: popup.visible
        onTriggered: popup.refresh()
    }

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
            spacing: 7

            Label {
                Layout.fillWidth: true
                text: "Audio mixer"
                color: rootShell.fg
                font.pixelSize: 12
                font.weight: Font.Bold
            }

            Repeater {
                model: popup.groups

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 6
                    color: rowMouse.containsMouse ? rootShell.bgHover : rootShell.bg
                    border.width: 1
                    border.color: rootShell.tooltipBorder
                    opacity: modelData.available ? 1 : 0.5

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Button {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 24
                            enabled: modelData.available
                            text: modelData.muted ? "M" : "~"
                            onClicked: popup.setGroupMuted(modelData, !modelData.muted)

                            contentItem: Label {
                                text: parent.text
                                color: parent.enabled ? rootShell.fg : rootShell.fgMuted
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }

                            background: Rectangle {
                                radius: 4
                                color: parent.down ? rootShell.accentSoft : parent.hovered ? rootShell.bgHover : "transparent"
                                border.width: 1
                                border.color: rootShell.tooltipBorder
                            }
                        }

                        ColumnLayout {
                            Layout.preferredWidth: 70
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

                            Label {
                                text: modelData.label
                                color: rootShell.fg
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }

                            Label {
                                text: modelData.available ? (modelData.ids.length > 1 ? `${modelData.ids.length} streams` : "active") : "not active"
                                color: rootShell.fgMuted
                                font.pixelSize: 9
                            }
                        }

                        Slider {
                            id: volumeSlider

                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: modelData.volume
                            enabled: modelData.available
                            onMoved: popup.setGroupVolume(modelData, value)
                        }

                        Label {
                            Layout.preferredWidth: 35
                            text: modelData.available ? `${modelData.volume}%` : "--"
                            color: rootShell.fg
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    MouseArea {
                        id: rowMouse

                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        onWheel: wheel => {
                            if (!modelData.available) return;
                            popup.setGroupVolume(modelData, modelData.volume + (wheel.angleDelta.y > 0 ? 5 : -5));
                            wheel.accepted = true;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: refreshProcess

        command: ["sh", "-c", "printf '__MIXER_MAIN__ '; wpctl get-volume @DEFAULT_AUDIO_SINK@; printf '\\n__MIXER_INPUTS__\\n'; pactl -f json list sink-inputs"]
        stdout: StdioCollector {
            onStreamFinished: {
                const marker = "__MIXER_INPUTS__\n";
                const markerIndex = text.indexOf(marker);
                if (markerIndex < 0) return;

                const mainText = text.slice(0, markerIndex);
                const inputText = text.slice(markerIndex + marker.length);
                const mainMatch = mainText.match(/Volume:\s+([0-9.]+)/);

                try {
                    const inputs = JSON.parse(inputText);
                    popup.groups = [
                        {
                            key: "main",
                            label: "Main",
                            ids: ["@DEFAULT_AUDIO_SINK@"],
                            volume: mainMatch ? Math.round(parseFloat(mainMatch[1]) * 100) : 0,
                            muted: mainText.includes("[MUTED]"),
                            available: !!mainMatch
                        },
                        popup.makeGroup("spotify", "Spotify", inputs),
                        popup.makeGroup("browser", "Browsers", inputs),
                        popup.makeGroup("discord", "Discord", inputs)
                    ];
                } catch (error) {
                    console.warn(`Could not read audio streams: ${error}`);
                }
            }
        }
    }

    Process {
        id: commandRunner

        onRunningChanged: {
            if (!running) popup.refresh();
        }
    }
}
