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
    property string legend
    property var label

    enabled: bridge.file.variant

    Controls.Menu {
        id: menu
        x: -menu.width / 2 + key.width / 2
        y: -menu.height + -Kirigami.Units.smallSpacing / 2

        onOpenedChanged: {
            if (opened == true) {
                editField.text = bridge.file.variant.getSymbol(key.keycode, key.symbolsLayer);
                editField.forceActiveFocus();
            }
        }
        RowLayout {
            Kirigami.SelectableLabel {
                text: key.keycode + ":"
            }
            Controls.TextField {
                id: editField
                implicitWidth: Kirigami.Units.gridUnit * 6
                onAccepted: {
                    bridge.file.variant.setSymbol(key.keycode, key.symbolsLayer, text.replace("U+", "U"));  // strip + for pasting from https://symbl.cc/
                    key.loadChars();
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
        text: parent.label ?? parent.char

        leftPadding: 5
        anchors.centerIn: parent
    }

    Controls.Label {
        id: fallback
        text: parent.charFallback
        opacity: 0.4
        visible: Settings.View.showFallbacks && !parent.char

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
        char = bridge.file.variant ? bridge.file.variant.getKeyChar(keycode, symbolsLayer) : "";
    }
    function loadFallback() {
        // Optimization!
        if (Settings.View.showFallbacks)
            charFallback = bridge.file.variant ? bridge.file.variant.getKeyCharFallback(keycode, symbolsLayer) : "";
    }

    checkable: true
    checked: menu.visible
    onClicked: {
        if (keycode)
            menu.open();
        else
            checked = false;
    }
}
