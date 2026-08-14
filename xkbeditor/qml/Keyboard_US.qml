pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 0
    property int symbolsLayer: 1
    property var keys: []

    DelegateModel {
        id: keyDelegate

        delegate: Key {
            required property var modelData
            keycode: modelData.keycode; legend: modelData.legend
            symbolsLayer: root.symbolsLayer
        }
    }

    ListModel {
        id: rowE
        ListElement { keycode: "TLDE"; legend: "`" }
        ListElement { keycode: "AE01"; legend: "1" }
        ListElement { keycode: "AE02"; legend: "2" }
        ListElement { keycode: "AE03"; legend: "3" }
        ListElement { keycode: "AE04"; legend: "4" }
        ListElement { keycode: "AE05"; legend: "5" }
        ListElement { keycode: "AE06"; legend: "6" }
        ListElement { keycode: "AE07"; legend: "7" }
        ListElement { keycode: "AE08"; legend: "8" }
        ListElement { keycode: "AE09"; legend: "9" }
        ListElement { keycode: "AE10"; legend: "0" }
        ListElement { keycode: "AE11"; legend: "-" }
        ListElement { keycode: "AE12"; legend: "=" }
    }

    ListModel {
        id: rowD
        ListElement { keycode: "AD01"; legend: "Q" }
        ListElement { keycode: "AD02"; legend: "W" }
        ListElement { keycode: "AD03"; legend: "E" }
        ListElement { keycode: "AD04"; legend: "R" }
        ListElement { keycode: "AD05"; legend: "T" }
        ListElement { keycode: "AD06"; legend: "Y" }
        ListElement { keycode: "AD07"; legend: "U" }
        ListElement { keycode: "AD08"; legend: "I" }
        ListElement { keycode: "AD09"; legend: "O" }
        ListElement { keycode: "AD10"; legend: "P" }
        ListElement { keycode: "AD11"; legend: "[" }
        ListElement { keycode: "AD12"; legend: "]" }
    }

    ListModel {
        id: rowC
        ListElement { keycode: "AC01"; legend: "A" }
        ListElement { keycode: "AC02"; legend: "S" }
        ListElement { keycode: "AC03"; legend: "D" }
        ListElement { keycode: "AC04"; legend: "F" }
        ListElement { keycode: "AC05"; legend: "G" }
        ListElement { keycode: "AC06"; legend: "H" }
        ListElement { keycode: "AC07"; legend: "J" }
        ListElement { keycode: "AC08"; legend: "K" }
        ListElement { keycode: "AC09"; legend: "L" }
        ListElement { keycode: "AC10"; legend: ";" }
        ListElement { keycode: "AC11"; legend: "'" }
    }

    ListModel {
        id: rowB
        ListElement { keycode: "AB01"; legend: "Z" }
        ListElement { keycode: "AB02"; legend: "X" }
        ListElement { keycode: "AB03"; legend: "C" }
        ListElement { keycode: "AB04"; legend: "V" }
        ListElement { keycode: "AB05"; legend: "B" }
        ListElement { keycode: "AB06"; legend: "N" }
        ListElement { keycode: "AB07"; legend: "M" }
        ListElement { keycode: "AB08"; legend: "," }
        ListElement { keycode: "AB09"; legend: "." }
        ListElement { keycode: "AB10"; legend: "/" }
    }

    RowLayout {
        spacing: 0
        Repeater {
            model: rowE
            delegate: keyDelegate.delegate
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
        Repeater {
            model: rowD
            delegate: keyDelegate.delegate
        }
        Key {
            keycode: "BKSL"; legend: "\\"
            unitWidth: unitSize * 1.5
        }
    }
    RowLayout {
        spacing: 0
        Key {
            label: "CapsLock"
            unitWidth: unitSize * 1.75
        }
        Repeater {
            model: rowC
            delegate: keyDelegate.delegate
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
        Repeater {
            model: rowB
            delegate: keyDelegate.delegate
        }
        Key {
            label: "Right Shift"
            unitWidth: unitSize * 2.75
        }
    }
}
