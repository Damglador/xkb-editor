import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import Settings as Settings

Controls.Button {
    id: key

    property var unitSize: Kirigami.Units.gridUnit * 3
    property var unitWidth: unitSize
    property var unitHeight: unitSize
    implicitWidth: unitWidth
    implicitHeight: unitHeight
    Layout.columnSpan: unitWidth / unitSize
    Layout.rowSpan: unitHeight / unitSize

    // Shared properties
    property int symbolsLayer: layerSelector.currentIndex + 1

    property string keycode
    property string char
    property string charFallback
    property string symbol
    property string symbolFallback

    property bool dead: symbol ? symbol.startsWith("dead_") : symbolFallback.startsWith("dead_")

    property string legend
    property var label

    enabled: bridge.file.variant

    Controls.Menu {
        id: menu
        x: -menu.width / 2 + key.width / 2
        y: -menu.height + -Kirigami.Units.smallSpacing / 2
        implicitWidth: Kirigami.Units.gridUnit * 8

        onVisibleChanged: {
            if (visible) {
                editField.text = key.symbol;
                editField.forceActiveFocus();
            }
        }
        RowLayout {
            Kirigami.SelectableLabel {
                text: key.keycode + ":"
            }
            Controls.TextField {
                id: editField
                Layout.fillWidth: true
                onAccepted: {
                    bridge.setSymbol(key.keycode, key.symbolsLayer, text.replace("U+", "U"));  // strip + for pasting from https://symbl.cc/
                    key.loadChar();
                    menu.close();
                }
            }
        }
    }

    Controls.Label {
        id: legend
        text: parent.legend
        opacity: 0.2
        visible: Settings.View.showLegends

        leftPadding: 5
        anchors.left: parent.left
        anchors.top: parent.top
    }

    Controls.Label {
        id: deadKeyIndicator
        text: "💀"
        visible: key.dead

        anchors.right: parent.right
        anchors.top: parent.top
    }

    Controls.Label {
        text: parent.label ?? parent.char

        leftPadding: 5
        anchors.centerIn: parent
    }

    Controls.Label {
        id: fallback
        text: parent.charFallback
        opacity: 0.4
        visible: Settings.View.showFallbacks && !parent.char && key.symbol != "VoidSymbol"

        anchors.centerIn: parent
    }

    onSymbolsLayerChanged: loadChars()
    Connections {
        target: bridge.file
        function onVariantChanged() {
            key.loadChars();
        }
    }
    Connections {
        target: bridge.file.variant
        function onIncludesReloaded() {
            key.loadFallback();
        }
        function onSymbolsChanged() {
            key.loadChar();
        }
    }
    Connections {
        target: Settings.View
        function onShowFallbacksChanged() {
            key.loadFallback();
        }
    }

    function loadChars() {
        loadChar();
        loadFallback();
    }
    function loadChar() {
        symbol = bridge.file.variant ? bridge.file.variant.getSymbol(keycode, symbolsLayer) : "";
        char = key.symbol ? bridge.getSymbolChar(key.symbol) : "";
    }
    function loadFallback() {
        // Optimization!
        if (Settings.View.showFallbacks) {
            symbolFallback = bridge.file.variant ? bridge.file.variant.getSymbolOrFallback(keycode, symbolsLayer) : "";
            charFallback = key.symbolFallback ? bridge.getSymbolChar(key.symbolFallback) : "";
        }

    }

    checkable: true
    checked: menu.visible
    onClicked: {
        if (keycode)
            menu.visible = !menu.visible
        else
            checked = false;
    }
}
