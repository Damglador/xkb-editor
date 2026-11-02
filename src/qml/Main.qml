pragma ComponentBehavior: Bound

import QtCore
import QtCore as QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import xkbeditor
import Settings as Settings

Kirigami.ApplicationWindow {
    id: window

    title: bridge.file.path ? Qt.application.name + " — " + bridge.file.path : Qt.application.name

    minimumWidth: Kirigami.Units.gridUnit * 46
    minimumHeight: Kirigami.Units.gridUnit * 22
    width: Kirigami.Units.gridUnit * 60
    height: Kirigami.Units.gridUnit * 22

    QtCore.Settings {
        category: "Window"
        location: Settings.Paths.stateFile
        property alias width: window.width
        property alias height: window.height
    }

    pageStack.initialPage: editorPage

    Bridge {
        id: bridge
    }

    menuBar: MenuBar {}

    EditorPage {
        id: editorPage
        Component.onCompleted: bridge.loadTestVariant()
        file: bridge.file
    }

    UndoStack {
        id: undoStack
    }

    FileDialog {
        id: openDialog
        title: "Open xkb layout"
        fileMode: FileDialog.OpenFile

        onAccepted: bridge.file.load(selectedFile)
        currentFolder: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0] + "/xkb/symbols"
    }
    FileDialog {
        id: saveDialog
        title: "Save xkb layout"
        fileMode: FileDialog.SaveFile

        onAccepted: if (bridge.file.write(selectedFile))
            bridge.file.path = selectedFile
        currentFolder: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0] + "/xkb/symbols"
    }
    FileDialog {
        id: importFileDialog
        title: qsTr("Open xkb layout")
        fileMode: FileDialog.OpenFile

        onAccepted: importDialogLoader.load(selectedFile)
        currentFolder: "file:///usr/share/xkeyboard-config-2/symbols/"
    }
    Loader {
        id: importDialogLoader
        active: false
        sourceComponent: ImportDialog {
            y: parent ? Math.round(((parent && parent.height) - implicitHeight) / 2) + Kirigami.Units.gridUnit * 2 * (1 - opacity) : 0 // move animation
        }
        function load(filePath) {
            active = true;
            item.load(filePath);
        }
        Connections {
            target: importDialogLoader.item
            function onClosed() {
                importDialogLoader.active = false;
            }
        }
    }

    Connections {
        target: bridge
        function onError(str) {
            statusBarLabel.setError(str);
        }
        function onNotify(str) {
            showPassiveNotification(str);
        }
    }

    Kirigami.AbstractCard {
        id: statusBar

        visible: false

        parent: window.overlay
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        padding: Kirigami.Units.smallSpacing

        Timer {
            id: timeout

            interval: 5000
            running: true
            repeat: false
            onTriggered: statusBar.visible = false
        }
        onVisibleChanged: if (visible == true)
            timeout.start()

        contentItem: RowLayout {
            HoverHandler {
                onHoveredChanged: if (hovered)
                    timeout.stop()
                else
                    timeout.start()
            }
            Kirigami.SelectableLabel {
                id: statusBarLabel

                function setStatus(str) {
                    text = str;
                    statusBar.visible = true;
                    color = Kirigami.Theme.textColor;
                }
                function setError(str) {
                    setStatus(qsTr("Error:") + " " + str);
                    color = Kirigami.Theme.negativeTextColor;
                }
                function setWarning(str) {
                    setStatus(qsTr("Warning:") + " " + str);
                    color = Kirigami.Theme.neutralBackgroundColor;
                }
            }
        }
    }

    About {
        id: about
        visible: false
    }

    KeysymTable {
        id: keysymTable
        visible: false
    }
}
