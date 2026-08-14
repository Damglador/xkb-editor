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

    property string keycode
    property var label

    text: label

    Component.onCompleted: {
        text = bridge.getKey(keycode, label);
    }

    onClicked: {
        console.log("rowSpan: " + Layout.rowSpan);
        console.log("columnSpan: " + Layout.columnSpan);
        console.log("unitWidth: " + unitWidth);
        console.log("unitHeight: " + unitHeight);
        console.log("unitSize: " + unitSize);
    }
}
