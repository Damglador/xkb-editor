pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 0
    property int symbolsLayer: 1
    property var keys: []

    RowLayout {
        spacing: 0
        property var keycodes: ["TLDE", "AE01", "AE02", "AE03", "AE04", "AE05", "AE06", "AE07", "AE08", "AE09", "AE10", "AE11", "AE12"]
        Repeater {
            model: parent.keycodes
            delegate: Key {
                required property var modelData
                keycode: modelData
                symbolsLayer: root.symbolsLayer
            }
        }
        Key {
            label: "Backspace"
            unitWidth: unitSize * 2
        }
    }
    RowLayout {
        spacing: 0
        Key {
            label: "Tab"
            unitWidth: unitSize * 1.5
        }
        property var keycodes: ["AD01", "AD02", "AD03", "AD04", "AD05", "AD06", "AD07", "AD08", "AD09", "AD10", "AD11", "AD12"]
        Repeater {
            model: parent.keycodes
            delegate: Key {
                required property var modelData
                keycode: modelData
                symbolsLayer: root.symbolsLayer
            }
        }

        Key {
            keycode: "BKSL"
            unitWidth: unitSize * 1.5
        }
    }
    RowLayout {
        spacing: 0
        Key {
            label: "CapsLock"
            unitWidth: unitSize * 1.75
        }
        property var keycodes: ["AC01", "AC02", "AC03", "AC04", "AC05", "AC06", "AC07", "AC08", "AC09", "AC10", "AC11"]
        Repeater {
            model: parent.keycodes
            delegate: Key {
                required property var modelData
                keycode: modelData
                symbolsLayer: root.symbolsLayer
            }
        }
        Key {
            label: "Enter"
            unitWidth: unitSize * 2.25
        }
    }
    RowLayout {
        spacing: 0
        Key {
            label: "Left Shift"
            unitWidth: unitSize * 2.25
        }
        property var keycodes: ["AB01", "AB02", "AB03", "AB04", "AB05", "AB06", "AB07", "AB08", "AB09", "AB10"]
        Repeater {
            model: parent.keycodes
            delegate: Key {
                required property var modelData
                keycode: modelData
                symbolsLayer: root.symbolsLayer
            }
        }
        Key {
            label: "Right Shift"
            unitWidth: unitSize * 2.75
        }
    }
}
