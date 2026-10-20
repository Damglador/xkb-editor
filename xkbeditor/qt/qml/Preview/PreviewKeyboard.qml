pragma ComponentBehavior: Bound

import QtQuick

import "../Keyboard"

Item {
    id: root
    required property var variant

    Keyboard_ANSI {
        delegate: PreviewKeyDelegate {
            required property var modelData
            keycode: modelData.keycode || keycode
            label: modelData.label || ""
            unitWidth: modelData.unitWidth || unitWidth
        }
    }
}
