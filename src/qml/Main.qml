pragma ComponentBehavior: Bound

import QtCore
import QtCore as QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as Controls
import Qt.labs.platform as Platform

import org.kde.kirigami as Kirigami

import xkbeditor

Kirigami.ApplicationWindow {
    id: window

    title: Bridge.file.path ? Qt.application.name + " — " + Bridge.file.path : Qt.application.name

    minimumWidth: Kirigami.Units.gridUnit * 46
    minimumHeight: Kirigami.Units.gridUnit * 22
    width: Kirigami.Units.gridUnit * 60
    height: Kirigami.Units.gridUnit * 22

    QtCore.Settings {
        category: "Window"
        location: Paths.stateFile
        property alias width: window.width
        property alias height: window.height
    }

    pageStack.initialPage: editorPage

    menuBar: MenuBar {}

    EditorPage {
        id: editorPage
        Component.onCompleted: Bridge.loadTestVariant()
        file: Bridge.file
    }

    UndoStack {
        id: undoStack
    }

    Platform.FileDialog {
        id: openDialog
        title: "Open xkb layout"
        fileMode: FileDialog.OpenFile

        onAccepted: Bridge.file.load(file)
        folder: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0] + "/xkb/symbols"
    }
    Platform.FileDialog {
        id: saveDialog
        title: "Save xkb layout"
        fileMode: FileDialog.SaveFile

        onAccepted: {
            let result = Bridge.file.write(file);
            if (result) {
                undoStack.setClean();
                Bridge.file.path = file;
            }
        }
        folder: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0] + "/xkb/symbols"
    }
    Platform.FileDialog {
        id: importFileDialog
        title: i18n("Open xkb layout")
        fileMode: FileDialog.OpenFile

        onAccepted: importDialogLoader.load(file)
        folder: "file:///usr/share/xkeyboard-config-2/symbols/"
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
        target: Bridge
        function onError(str) {
            statusBarLabel.setError(str);
        }
        function onNotify(str) {
            showPassiveNotification(str);
        }
        function onFileChanged() {
            undoStack.clear();
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
                    setStatus(i18n("Error:") + " " + str);
                    color = Kirigami.Theme.negativeTextColor;
                }
                function setWarning(str) {
                    setStatus(i18n("Warning:") + " " + str);
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

    property bool closing: false
    onClosing: (close) => {
        close.accepted = closing;
        destructive(() => {
            closing = true;
            window.close();
        });
    }
    function save() {
        if (Bridge.file.path) {
            let result = Bridge.file.write(Bridge.file.path);
            if (result) {
                undoStack.setClean();
            }
            return result;
        }
        Bridge.error(i18n("Please use «Save As...»"));
        return false;
    }
    function destructive(callback) {
        if (undoStack.isClean())
            callback();
        else
            unsavedDialog.prompt(callback);
    }
    Kirigami.PromptDialog {
        id: unsavedDialog
        property var postAction
        modal: true
        iconName: "dialog-warning"
        title: "You have unsaved changes"
        subtitle: "Do you want to save them?"
        standardButtons: Kirigami.Dialog.Save | Kirigami.Dialog.Discard
        onAccepted: {
            close();
            if (window.save())
                postAction();
        }
        onDiscarded: {
            close();
            postAction();
        }
        function prompt(callback) {
            postAction = callback;
            open();
        }
    }
}
