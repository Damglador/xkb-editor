import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

ColumnLayout {
    anchors.centerIn: parent

    Keyboard_US {
        id: keyboard
    }
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Controls.Label {
            text: qsTr("Layer:")
        }
        Repeater {
            model: [1, 2, 3, 4]
            delegate: Controls.Button {
                required property int modelData

                text: modelData.toString()
                checked: keyboard.symbolsLayer == modelData
                onClicked: {
                    keyboard.symbolsLayer = modelData;
                }
            }
        }
    }
}
