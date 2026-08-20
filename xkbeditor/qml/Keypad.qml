import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 0

    property int symbolsLayer: 1

    GridLayout {
        columnSpacing: 0
        rowSpacing: 0
        columns: 4
        Key { label: "Num\nLock" }
        Key { keycode: "KPDV"; legend: "/" }
        Key { keycode: "KPMU"; legend: "*" }
        Key { keycode: "KPSU"; legend: "-" }
        Key { keycode: "KP7";  legend: "7" }
        Key { keycode: "KP8";  legend: "8" }
        Key { keycode: "KP9";  legend: "9" }
        Key { keycode: "KPAD"; legend: "+";    unitHeight: unitSize * 2 }
        Key { keycode: "KP4";  legend: "4" }
        Key { keycode: "KP5";  legend: "5" }
        Key { keycode: "KP6";  legend: "6" }
        Key { keycode: "KP1";  legend: "1" }
        Key { keycode: "KP2";  legend: "2" }
        Key { keycode: "KP3";  legend: "3" }
        Key { keycode: "KPEN"; label: "Enter"; unitHeight: unitSize * 2 }
        Key { keycode: "KP0";  legend: "0";    unitWidth:  unitSize * 2 }
        Key { keycode: "KPPT"; legend: "." }
    }
}
