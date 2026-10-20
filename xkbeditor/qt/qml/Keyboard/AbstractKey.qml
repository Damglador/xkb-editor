import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item {
    property var unitSize: Kirigami.Units.gridUnit * 3
    property var unitWidth: 1
    property var unitHeight: 1
    implicitWidth: unitWidth * unitSize
    implicitHeight: unitHeight * unitSize
    Layout.columnSpan: unitWidth
    Layout.rowSpan: unitHeight

    property string keycode
    property string label
}
