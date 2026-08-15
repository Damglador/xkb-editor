import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Controls.Button {
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
    property string legend
    property var label

    text: label

    Controls.Label {
        id: legend

        visible: legendToggle.checked

        leftPadding: 5
        anchors.left: parent.left
        anchors.top: parent.top

        text: parent.legend

        opacity: 0.5
    }

    onSymbolsLayerChanged: {
        text = bridge.getKeyChar(keycode, symbolsLayer, label);
    }

    onClicked: {
        console.log("keycode: " + keycode);
    }
}
