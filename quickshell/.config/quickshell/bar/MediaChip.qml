import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: chip

    required property var rootShell
    property var player: rootShell.activePlayer()

    function trackText(): string {
        if (!player) return "Nothing playing";

        const title = player.trackTitle || "Unknown Title";
        const artist = player.trackArtist || player.identity || "Unknown Artist";

        return `${title} - ${artist}`;
    }

    radius: 6
    color: rootShell.accentSoft
    border.width: 1
    border.color: rootShell.accentLine
    implicitHeight: 24
    implicitWidth: Math.max(mediaControls.implicitWidth + 12, implicitHeight)

    ToolTip.visible: hoverArea.containsMouse
    ToolTip.delay: 200
    ToolTip.text: chip.trackText()

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
    }

    RowLayout {
        id: mediaControls

        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: 4

        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 5
            color: prevMouse.containsMouse ? rootShell.bgHover : "transparent"
            opacity: player && player.canGoPrevious ? 1 : 0.45

            Label {
                anchors.centerIn: parent
                text: "<<"
                color: rootShell.fg
                font.pixelSize: 10
                font.weight: Font.Medium
            }

            MouseArea {
                id: prevMouse

                anchors.fill: parent
                hoverEnabled: true
                enabled: player && player.canGoPrevious
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: player.previous()
            }
        }

        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 5
            color: toggleMouse.containsMouse ? rootShell.bgHover : rootShell.bg
            opacity: player && player.canTogglePlaying ? 1 : 0.45

            Label {
                anchors.centerIn: parent
                text: player && player.isPlaying ? "||" : ">"
                color: rootShell.accent
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            MouseArea {
                id: toggleMouse

                anchors.fill: parent
                hoverEnabled: true
                enabled: player && player.canTogglePlaying
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: player.togglePlaying()
            }
        }

        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 5
            color: nextMouse.containsMouse ? rootShell.bgHover : "transparent"
            opacity: player && player.canGoNext ? 1 : 0.45

            Label {
                anchors.centerIn: parent
                text: ">>"
                color: rootShell.fg
                font.pixelSize: 10
                font.weight: Font.Medium
            }

            MouseArea {
                id: nextMouse

                anchors.fill: parent
                hoverEnabled: true
                enabled: player && player.canGoNext
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: player.next()
            }
        }
    }
}
