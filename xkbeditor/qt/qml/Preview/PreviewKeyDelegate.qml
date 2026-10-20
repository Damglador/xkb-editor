pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import "../Keyboard"

AbstractKey {
    id: keyItem

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
