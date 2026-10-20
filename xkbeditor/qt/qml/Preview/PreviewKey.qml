pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import "../Keyboard"

AbstractKey {
    id: key
    property double zoom: 1

    implicitWidth: unitWidth * unitSize * zoom
    implicitHeight: unitHeight * unitSize * zoom

    Rectangle {
        anchors.fill: parent
        color: parent.label ? "gray" : "white"
        border.width: Kirigami.Units.smallSpacing / 2
        border.color: "black"
        radius: Kirigami.Units.cornerRadius
    }

    Controls.Label {
        text: parent.label || ""

        leftPadding: 5
        anchors.centerIn: parent
        font.pointSize: 10 * key.zoom
        color: "black"
    }

    GridLayout {
        columns: 2
        rows: 2
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing

        uniformCellWidths: true
        uniformCellHeights: true

        CharLabel {
            level: 1
            // Bottom left
            Layout.row: 1
            Layout.column: 0
            Layout.alignment: Qt.AlignHCenter
        }
        CharLabel {
            level: 2
            // Top left
            Layout.row: 0
            Layout.column: 0
            Layout.alignment: Qt.AlignCenter
        }
        CharLabel {
            level: 3
            // Bottom right
            Layout.row: 1
            Layout.column: 1
            Layout.alignment: Qt.AlignCenter
        }
        CharLabel {
            level: 4
            // Top right
            Layout.row: 0
            Layout.column: 1
            Layout.alignment: Qt.AlignCenter
        }
    }
}
