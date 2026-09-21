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

    Controls.ToolTip {
        id: tooltip

        contentItem: RowLayout {
            Kirigami.SelectableLabel {
                text: key.keycode + ":"
            }
            Controls.TextField {
                implicitWidth: Kirigami.Units.gridUnit * 6
                onVisibleChanged: {
                    if (visible == true)
                        text = bridge.file.variant.getSymbol(key.keycode, key.symbolsLayer)
                        forceActiveFocus()
                }
                onAccepted: {
                  bridge.file.variant.setSymbol(key.keycode, key.symbolsLayer, text)
                  key.loadChars()
                  tooltip.visible = !tooltip.visible
                }
            }
        }
        delay: 50
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
        target: Settings.View
        function onShowFallbacksChanged() {
            key.loadChars();
        }
    }

    function loadChars() {
        if (bridge.file.variant) {
            char = bridge.file.variant.getKeyChar(keycode, symbolsLayer);
            // Optimization!
            if (Settings.View.showFallbacks) charFallback = bridge.file.variant.getKeyCharFallback(keycode, symbolsLayer);
        }
        else {
            char = ""
            charFallback = ""
        }
    }

    checkable: true
    checked: tooltip.visible
    onClicked: {
        if (keycode) tooltip.visible = !tooltip.visible;
        else checked = false
    }
}
