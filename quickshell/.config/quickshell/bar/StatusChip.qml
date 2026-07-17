import QtQuick

Rectangle {
    id: chip

    property string text: ""
    property color bgColor
    property color fgColor
    property color borderColor
    property bool clickable: false
    property alias mouseArea: chipMouseArea

    radius: 6
    color: bgColor
    border.width: 1
    border.color: borderColor
    implicitHeight: 24
    implicitWidth: Math.max(contentRow.implicitWidth + 18, implicitHeight)

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 0

        Text {
            text: chip.text
            color: chip.fgColor
            font.pixelSize: 11
            font.weight: Font.Medium
            visible: text !== ""
        }
    }

    MouseArea {
        id: chipMouseArea

        anchors.fill: parent
        enabled: chip.clickable
        hoverEnabled: chip.clickable
        cursorShape: chip.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
