import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

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
    property int symbolsLayer: keyboard.symbolsLayer

    property string keycode
    property string char
    property string charFallback
    property string legend
    property var label

    text: label ?? char

    Controls.Label {
        id: legend

        visible: legendsToggle.checked

        leftPadding: 5
        anchors.left: parent.left
        anchors.top: parent.top

        text: parent.legend

        opacity: 0.2
    }

    Controls.Label {
        id: fallback

        visible: fallbacksToggle.checked && !parent.char

        anchors.centerIn: parent

        text: parent.charFallback

        opacity: 0.4
    }

    onSymbolsLayerChanged: loadChars()
    Connections {
        target: bridge
        function onVariantChanged() {
            key.loadChars()
        }
    }

    function loadChars() {
        char = bridge.getKeyChar(keycode, symbolsLayer);
        charFallback = bridge.getKeyCharFallback(keycode, symbolsLayer);
    }

    onClicked: {
        console.log("keycode: " + keycode);
    }
}
