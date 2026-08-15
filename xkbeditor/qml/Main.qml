import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import project

Kirigami.ApplicationWindow {
    id: root

    title: qsTr("XkbEditor")

    minimumWidth: Kirigami.Units.gridUnit * 60
    minimumHeight: Kirigami.Units.gridUnit * 20
    width: minimumWidth
    height: minimumHeight

    pageStack.initialPage: initPage

    Component {
        id: initPage

        Kirigami.Page {
            ColumnLayout {
                anchors.centerIn: parent

                RowLayout {
                    Controls.Switch {
                        id: legendToggle
                        text: "Show legends"
                        checked: true
                    }
                }
                Keyboard_US {
                    id: keyboard
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Controls.Label {
                        text: "Layer:"
                    }
                    Controls.Button {
                        text: "1"
                        onClicked: {
                            keyboard.symbolsLayer = 1;
                        }
                    }
                    Controls.Button {
                        text: "2"
                        onClicked: {
                            keyboard.symbolsLayer = 2;
                        }
                    }
                    Controls.Button {
                        text: "3"
                        onClicked: {
                            keyboard.symbolsLayer = 3;
                        }
                    }
                    Controls.Button {
                        text: "4"
                        onClicked: {
                            keyboard.symbolsLayer = 4;
                        }
                    }
                }
            }

            Bridge {
                id: bridge
            }
        }
    }
}
