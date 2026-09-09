pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 0

    RowLayout {
        id: rowE
        spacing: 0
        Key { keycode: "TLDE"; legend: "`" }
        Key { keycode: "AE01"; legend: "1" }
        Key { keycode: "AE02"; legend: "2" }
        Key { keycode: "AE03"; legend: "3" }
        Key { keycode: "AE04"; legend: "4" }
        Key { keycode: "AE05"; legend: "5" }
        Key { keycode: "AE06"; legend: "6" }
        Key { keycode: "AE07"; legend: "7" }
        Key { keycode: "AE08"; legend: "8" }
        Key { keycode: "AE09"; legend: "9" }
        Key { keycode: "AE10"; legend: "0" }
        Key { keycode: "AE11"; legend: "-" }
        Key { keycode: "AE12"; legend: "=" }
        Key {
            label: "Backspace"
            unitWidth: unitSize * 2
        }
    }

    RowLayout {
        id: rowD
        spacing: 0
        Key {
            label: "Tab"
            unitWidth: unitSize * 1.5
        }
        Key { keycode: "AD01"; legend: "Q" }
        Key { keycode: "AD02"; legend: "W" }
        Key { keycode: "AD03"; legend: "E" }
        Key { keycode: "AD04"; legend: "R" }
        Key { keycode: "AD05"; legend: "T" }
        Key { keycode: "AD06"; legend: "Y" }
        Key { keycode: "AD07"; legend: "U" }
        Key { keycode: "AD08"; legend: "I" }
        Key { keycode: "AD09"; legend: "O" }
        Key { keycode: "AD10"; legend: "P" }
        Key { keycode: "AD11"; legend: "[" }
        Key { keycode: "AD12"; legend: "]" }
        Key { keycode: "BKSL"; legend: "\\"; unitWidth: unitSize * 1.5 }
    }

    RowLayout {
        id: rowC
        spacing: 0
        Key {
            label: "CapsLock"
            unitWidth: unitSize * 1.75
        }
        Key { keycode: "AC01"; legend: "A" }
        Key { keycode: "AC02"; legend: "S" }
        Key { keycode: "AC03"; legend: "D" }
        Key { keycode: "AC04"; legend: "F" }
        Key { keycode: "AC05"; legend: "G" }
        Key { keycode: "AC06"; legend: "H" }
        Key { keycode: "AC07"; legend: "J" }
        Key { keycode: "AC08"; legend: "K" }
        Key { keycode: "AC09"; legend: "L" }
        Key { keycode: "AC10"; legend: ";" }
        Key { keycode: "AC11"; legend: "'" }
        Key {
            label: "Enter"
            unitWidth: unitSize * 2.25
        }
    }

    RowLayout {
        id: rowB
        spacing: 0
        Key {
            label: "Left Shift"
            unitWidth: unitSize * 2.25
        }
        Key { keycode: "AB01"; legend: "Z" }
        Key { keycode: "AB02"; legend: "X" }
        Key { keycode: "AB03"; legend: "C" }
        Key { keycode: "AB04"; legend: "V" }
        Key { keycode: "AB05"; legend: "B" }
        Key { keycode: "AB06"; legend: "N" }
        Key { keycode: "AB07"; legend: "M" }
        Key { keycode: "AB08"; legend: "," }
        Key { keycode: "AB09"; legend: "." }
        Key { keycode: "AB10"; legend: "/" }
        Key {
            label: "Right Shift"
            unitWidth: unitSize * 2.75
        }
    }
}
