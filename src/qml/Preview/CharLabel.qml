import QtQuick
import QtQuick.Controls as Controls

import xkbeditor

Controls.Label {
    required property int level
    property string symbol: root.variant ? root.variant.getSymbolOrFallback(key.keycode, level, true) : "";
    property string char: symbol ? Bridge.getSymbolChar(symbol) : "";
    property bool dead: symbol.startsWith("dead_")

    text: char

    font.pointSize: Math.max(key.unitSize / 6, 1)
    color: dead ? "red" : (level < 3 ? "black" : "gray")
}
