pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import Settings as Settings

Item {
    id: keyItem
    property string keycode
    property var label

    property var unitSize: Kirigami.Units.gridUnit * 3
    property var unitWidth: 1
    property var unitHeight: 1
    implicitWidth: unitWidth * unitSize
    implicitHeight: unitHeight * unitSize
    Layout.columnSpan: unitWidth
    Layout.rowSpan: unitHeight

    PreviewKey {
        keycode:    keyItem.keycode
        label:      keyItem.label
        unitWidth:  keyItem.unitWidth
        unitHeight: keyItem.unitHeight
    }

    HoverHandler {
        id: hoverHandler
    }

    Controls.ToolTip {
        contentItem: PreviewKey {
            zoom: 2
            keycode: keyItem.keycode
            label: keyItem.label
            unitWidth:  keyItem.unitWidth
            unitHeight: keyItem.unitHeight
        }
        visible: hoverHandler.hovered
    }
}
