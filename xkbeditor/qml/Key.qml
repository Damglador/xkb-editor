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

    property int symbolsLayer

    property string keycode
    property string legend
    property var label

    text: label

    Controls.Label {
        leftPadding: 5
        anchors.left: parent.left
        anchors.top: parent.top

        text: parent.legend

        opacity: 0.5
    }

    onSymbolsLayerChanged: {
        text = bridge.getKey(keycode, symbolsLayer, label);
    }

    Component.onCompleted: {
        text = bridge.getKey(keycode, symbolsLayer, label);
    }

    onClicked: {
        console.log("rowSpan: " + Layout.rowSpan);
        console.log("columnSpan: " + Layout.columnSpan);
        console.log("unitWidth: " + unitWidth);
        console.log("unitHeight: " + unitHeight);
        console.log("unitSize: " + unitSize);
    }
}
