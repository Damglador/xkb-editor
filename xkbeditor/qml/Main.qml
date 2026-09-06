import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import project

Kirigami.ApplicationWindow {
    id: window

    title: "XkbEditor"

    minimumWidth: Kirigami.Units.gridUnit * 60
    minimumHeight: Kirigami.Units.gridUnit * 20
    width: minimumWidth
    height: minimumHeight

    pageStack.initialPage: initPage

    Bridge {
        id: bridge
    }

    Controls.MenuBar {
        Controls.Menu {
            title: "File"
            Kirigami.Action {
                text: "Open"
                icon.name: "document-open"
                onTriggered: openDialog.open()
            }
            Kirigami.Action {
                text: "Save"
                icon.name: "document-save"
                onTriggered: {
                    if (bridge.openedFilePath)
                        bridge.saveFile(bridge.openedFilePath);
                    else
                        saveDialog.open();
                }
            }
            Kirigami.Action {
                text: "Save As"
                icon.name: "document-save-as"
                onTriggered: saveDialog.open()
            }
        }
        Controls.Menu {
            title: qsTr("View")
            Kirigami.Action {
                id: legendsToggle
                text: qsTr("Show legends")
                checkable: true
                checked: true
            }
            Kirigami.Action {
                id: fallbacksToggle
                text: qsTr("Show fallback characters")
                checkable: true
                checked: true
            }
        }
    }

    Component {
        id: initPage

        Kirigami.Page {
            Editor {
                anchors.centerIn: parent
            }
            Component.onCompleted: bridge.loadTestVariant()
        }
    }

    FileDialog {
        id: openDialog
        title: "Open xkb layout"
        fileMode: FileDialog.OpenFile

        onAccepted: bridge.openFile(selectedFile)
        currentFolder: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0] + "/xkb/symbols"
    }
    FileDialog {
        id: saveDialog
        title: "Save xkb layout"
        fileMode: FileDialog.SaveFile

        onAccepted: bridge.saveFile(selectedFile)
        currentFolder: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0] + "/xkb/symbols"
    }

    Connections {
        target: bridge
        function onError(str) {
            statusBarLabel.setStatus("Error: " + str);
        }
    }

    Kirigami.AbstractCard {
        id: statusBar

        visible: false

        parent: window.overlay
        anchors.bottom: parent.bottom
        anchors.left: parent.top
        padding: Kirigami.Units.smallSpacing

        Timer {
            id: timeout

            interval: 5000
            running: true
            repeat: false
            onTriggered: statusBar.visible = false
        }
        onVisibleChanged: if (visible == true) timeout.start()

        contentItem: RowLayout {
            Kirigami.SelectableLabel {
                id: statusBarLabel

                function setStatus(str) {
                    text = str
                    statusBar.visible = true
                }
            }
        }
    }
}
