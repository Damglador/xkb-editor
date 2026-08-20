import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import project

Kirigami.ApplicationWindow {
    id: window

    title: qsTr("XkbEditor")

    minimumWidth: Kirigami.Units.gridUnit * 60
    minimumHeight: Kirigami.Units.gridUnit * 20
    width: minimumWidth
    height: minimumHeight

    pageStack.initialPage: initPage

    Bridge {
        id: bridge
    }

    Component {
        id: initPage

        Kirigami.Page {
            ColumnLayout {
                anchors.centerIn: parent

                RowLayout {
                    Controls.Switch {
                        id: legendToggle
                        text: qsTr("Show legends")
                        checked: true
                        Controls.ToolTip.text: qsTr("Show characters from a physical QWERTY keyboard")
                        Controls.ToolTip.visible: hovered
                    }
                    Controls.Switch {
                        id: fallbacksToggle
                        text: qsTr("Show fallbacks")
                        checked: true
                        Controls.ToolTip.text: qsTr("Show characters from included layouts")
                        Controls.ToolTip.visible: hovered
                    }
                }
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
        }
    }
}
