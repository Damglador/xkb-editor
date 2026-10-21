pragma ComponentBehavior: Bound

import QtQuick

import "../Keyboard"

Item {
    id: root
    required property var variant

    implicitHeight: childrenRect.height

    Keyboard_ANSI {
        delegate: PreviewKeyDelegate {
            required property var modelData
            unitSize: root.width / 15
            keycode: modelData.keycode || keycode
            label: modelData.label || ""
            unitWidth: modelData.unitWidth || unitWidth
        }
    }
}
