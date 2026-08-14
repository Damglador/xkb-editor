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
                Keyboard_US {
                    id: layout
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Controls.Label {
                        text: "Layer:"
                    }
                    Controls.Button {
                        text: "1"
                        onClicked: {
                            layout.symbolsLayer = 1;
                        }
                    }
                    Controls.Button {
                        text: "2"
                        onClicked: {
                            layout.symbolsLayer = 2;
                        }
                    }
                    Controls.Button {
                        text: "3"
                        onClicked: {
                            layout.symbolsLayer = 3;
                        }
                    }
                    Controls.Button {
                        text: "4"
                        onClicked: {
                            layout.symbolsLayer = 4;
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
