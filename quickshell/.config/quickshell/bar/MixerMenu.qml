import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import Quickshell
import Quickshell.Io

PopupWindow {
    id: popup

    required property var rootShell
    required property var anchorItem
    property var groups: []
    property var knownStreamIds: ({})

    Settings {
        id: mixerSettings

        category: "audioMixer"
    }

    function savedVolume(key: string): number {
        return Number(mixerSettings.value(`${key}Volume`, -1));
    }

    function saveVolume(key: string, volume: real): void {
        mixerSettings.setValue(`${key}Volume`, Math.round(volume));
        mixerSettings.sync();
    }

    function matchesGroup(input: var, key: string): bool {
        const properties = input.properties || {};
        const name = `${properties["application.name"] || ""} ${properties["application.process.binary"] || ""} ${properties["media.name"] || ""}`.toLowerCase();

        if (key === "spotify") return /spotify/.test(name);
        if (key === "browser") return /(helium|zen|floorp|brave)/.test(name);
        if (key === "discord") return /discord/.test(name);
        if (key === "other") {
            return !matchesGroup(input, "spotify")
                && !matchesGroup(input, "browser")
                && !matchesGroup(input, "discord");
        }

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

    function restoreNewStreamVolumes(discoveredGroups: var): void {
        const nextKnownIds = {};
        const commands = [];

        for (const group of discoveredGroups) {
            const saved = savedVolume(group.key);
            const knownIds = knownStreamIds[group.key] || [];
            const newIds = group.ids.filter(id => !knownIds.includes(id));
            nextKnownIds[group.key] = group.ids;

            if (!group.available) continue;

            if (saved < 0) {
                saveVolume(group.key, group.volume);
                continue;
            }

            const needsRestore = newIds.length || group.volume !== saved;
            group.volume = saved;
            if (needsRestore) {
                commands.push(...group.ids.map(id => `pactl set-sink-input-volume ${id} ${saved}%`));
            }
        }

        knownStreamIds = nextKnownIds;

        if (!commands.length || restoreRunner.running) return;
        restoreRunner.command = ["sh", "-c", commands.join(" && ")];
        restoreRunner.running = true;
    }

    function setGroupVolume(group: var, volume: real): void {
        const target = Math.max(0, Math.min(100, Math.round(volume)));
        const command = group.ids.map(id => `pactl set-sink-input-volume ${id} ${target}%`).join(" && ");

        if (!command) return;
        saveVolume(group.key, target);
        commandRunner.command = ["sh", "-c", `${command}; sleep 0.08`];
        commandRunner.running = true;
    }

    function setGroupMuted(group: var, muted: bool): void {
        const command = group.ids.map(id => `pactl set-sink-input-mute ${id} ${muted ? 1 : 0}`).join(" && ");

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
        radius: 0
        color: rootShell.menuBg
        border.width: 1
        border.color: rootShell.barBorder
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
                    radius: 0
                    color: rowMouse.containsMouse ? rootShell.bgHover : rootShell.chipBg
                    border.width: 1
                    border.color: rootShell.barBorder
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
                                radius: 0
                                color: parent.down ? rootShell.accentSoft : parent.hovered ? rootShell.bgHover : "transparent"
                                border.width: 1
                                border.color: rootShell.barBorder
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

        command: ["pactl", "-f", "json", "list", "sink-inputs"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const inputs = JSON.parse(text);
                    const discoveredGroups = [
                        popup.makeGroup("other", "Other apps", inputs),
                        popup.makeGroup("spotify", "Spotify", inputs),
                        popup.makeGroup("browser", "Browsers", inputs),
                        popup.makeGroup("discord", "Discord", inputs)
                    ];
                    popup.restoreNewStreamVolumes(discoveredGroups);
                    popup.groups = discoveredGroups;
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

    Process {
        id: restoreRunner
    }
}
