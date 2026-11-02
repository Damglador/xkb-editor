import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import Settings as Settings

AbstractKey {
    id: key

    // Shared properties
    property int level: levelSelector.currentIndex + 1

    property string char
    property string charFallback
    property string symbol
    property string symbolFallback

    property bool dead: symbol ? symbol.startsWith("dead_") : symbolFallback.startsWith("dead_")

    property string legend

    Controls.Button {
        id: keyButton
        anchors.fill: parent
        enabled: root.variant

        checkable: key.keycode
        checked: menu.visible
    }

    Controls.Menu {
        id: menu
        visible: keyButton.checked
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
                    undoStack.setSymbol(root.variant, key.keycode, key.level, text.replace("U+", "U"));  // strip + for pasting from https://symbl.cc/
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
        text: parent.label ? parent.label : parent.char

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

    onLevelChanged: {
        menu.close();
        loadChars();
    }

    Connections {
        target: bridge.file
        function onVariantChanged() {
            key.loadChars();
        }
    }
    Connections {
        target: root.variant
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
        symbol = root.variant ? root.variant.getSymbol(keycode, level) : "";
        char = key.symbol ? bridge.getSymbolChar(key.symbol) : "";
    }
    function loadFallback() {
        // Optimization!
        if (Settings.View.showFallbacks) {
            symbolFallback = root.variant ? root.variant.getSymbolOrFallback(keycode, level) : "";
            charFallback = key.symbolFallback ? bridge.getSymbolChar(key.symbolFallback) : "";
        }
    }
}
