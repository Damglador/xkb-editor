pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../Keyboard"

Item {
    id: root
    property var variant: bridge.file.variant
    Keyboard_ANSI {
        delegate: PreviewKeyDelegate {
            required property var modelData
            keycode: modelData.keycode || keycode
            label: modelData.label || ""
            unitWidth: modelData.unitWidth || unitWidth
        }
    }
}
