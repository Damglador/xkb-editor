import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
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
            Editor {}
            Component.onCompleted: bridge.loadTestVariant()
        }
    }

    FileDialog {
        id: openDialog
        title: "Open xkb layout"
        fileMode: FileDialog.OpenFile
    }
    FileDialog {
        id: saveDialog
        title: "Save xkb layout"
        fileMode: FileDialog.SaveFile

    }
}
