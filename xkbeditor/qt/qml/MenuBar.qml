import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import Settings as Settings

Controls.MenuBar {
    Controls.Menu {
        title: qsTr("File")
        Kirigami.Action {
            text: "New"
            icon.name: "document-new"
            onTriggered: bridge.newFile()
        }
        Kirigami.Action {
            text: qsTr("Open")
            icon.name: "document-open"
            onTriggered: openDialog.open()
            shortcut: StandardKey.Open
        }
        Kirigami.Action {
            text: qsTr("Save")
            icon.name: "document-save"
            onTriggered: {
                if (bridge.file.path)
                    bridge.file.write(bridge.file.path);
                else
                    saveDialog.open();
            }
            shortcut: StandardKey.Save
        }
        Kirigami.Action {
            text: qsTr("Save As")
            icon.name: "document-save-as"
            onTriggered: saveDialog.open()
            shortcut: StandardKey.SaveAs
        }
    }
    Controls.Menu {
        title: qsTr("Edit")
        Kirigami.Action {
            text: bridge.undoStack.undoText ? "Undo: " + bridge.undoStack.undoText : "Undo"
            icon.name: "edit-undo"
            enabled: bridge.undoStack.canUndo
            onTriggered: bridge.undoStack.undo()
            shortcut: StandardKey.Undo
        }
        Kirigami.Action {
            text: bridge.undoStack.redoText ? "Redo: " + bridge.undoStack.redoText : "Redo"
            icon.name: "edit-redo"
            enabled: bridge.undoStack.canRedo
            onTriggered: bridge.undoStack.redo()
            shortcut: StandardKey.Redo
        }
    }
    Controls.Menu {
        title: qsTr("View")
        Kirigami.Action {
            text: qsTr("Show legends")
            checkable: true
            checked: Settings.View.showLegends
            onToggled: Settings.View.showLegends = checked
        }
        Kirigami.Action {
            text: qsTr("Show fallback characters")
            checkable: true
            checked: Settings.View.showFallbacks
            onToggled: Settings.View.showFallbacks = checked
        }
        Kirigami.Action {
            text: qsTr("Variants sidebar")
            checkable: true
            checked: Settings.View.variantsSidebar
            onToggled: Settings.View.variantsSidebar = checked
        }
    }
    Controls.Menu {
        title: qsTr("Help")
        Kirigami.Action {
            text: qsTr("Unicode table")
            icon.name: "table"
            onTriggered: Qt.openUrlExternally("https://symbl.cc/en/unicode-table/")
        }
        Kirigami.Action {
            text: qsTr("Xkb documentation")
            icon.name: "documentation"
            onTriggered: Qt.openUrlExternally("https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#the-xkb_symbols-section")
        }
        Kirigami.Action {
            text: qsTr("About")
            icon.name: "help-about"
            onTriggered: about.show()
        }
    }
}
