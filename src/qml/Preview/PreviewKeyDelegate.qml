pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import "../Keyboard"

AbstractKey {
    id: keyItem

    PreviewKey {
        keycode:    keyItem.keycode
        label:      keyItem.label
        unitSize:   keyItem.unitSize
        unitWidth:  keyItem.unitWidth
        unitHeight: keyItem.unitHeight
    }

    HoverHandler {
        id: hoverHandler
    }

    Controls.ToolTip {
        contentItem: PreviewKey {
            keycode: keyItem.keycode
            label: keyItem.label
            unitSize: keyItem.unitSize * 2
            unitWidth:  keyItem.unitWidth
            unitHeight: keyItem.unitHeight
        }
        visible: hoverHandler.hovered
    }
}
