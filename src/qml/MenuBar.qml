import QtQuick
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import xkbeditor

Controls.MenuBar {
    Controls.Menu {
        title: i18n("File")
        Kirigami.Action {
            text: i18n("New")
            icon.name: "document-new"
            onTriggered: window.destructive(() => Bridge.file.clear())
        }
        Kirigami.Action {
            text: i18n("Open...")
            icon.name: "document-open"
            onTriggered: window.destructive(() => openDialog.open())
            shortcut: StandardKey.Open
        }
        Kirigami.Action {
            text: i18n("Save")
            icon.name: "document-save"
            onTriggered: {
                if (Bridge.file.path) {
                    window.save();
                } else {
                    saveDialog.open();
                }
            }
            shortcut: StandardKey.Save
        }
        Kirigami.Action {
            text: i18n("Save As...")
            icon.name: "document-save-as"
            onTriggered: saveDialog.open()
            shortcut: StandardKey.SaveAs
        }
    }
    Controls.Menu {
        title: i18n("Edit")
        Kirigami.Action {
            text: undoStack.undoText ? i18n("Undo") + ": " + undoStack.undoText : i18n("Undo")
            icon.name: "edit-undo"
            enabled: undoStack.canUndo
            onTriggered: undoStack.undo()
            shortcut: StandardKey.Undo
        }
        Kirigami.Action {
            text: undoStack.redoText ? i18n("Redo") + ": " + undoStack.redoText : i18n("Redo")
            icon.name: "edit-redo"
            enabled: undoStack.canRedo
            onTriggered: undoStack.redo()
            shortcut: StandardKey.Redo
        }
        Kirigami.Action {
            text: i18n("Import variants...")
            icon.name: "document-import"
            onTriggered: importFileDialog.open()
        }
    }
    Controls.Menu {
        title: i18n("View")
        Kirigami.Action {
            text: i18n("Show legends")
            checkable: true
            checked: ViewSettings.showLegends
            onToggled: ViewSettings.showLegends = checked
        }
        Kirigami.Action {
            text: i18n("Show fallback characters")
            checkable: true
            checked: ViewSettings.showFallbacks
            onToggled: ViewSettings.showFallbacks = checked
        }
        Kirigami.Action {
            text: i18n("Variants sidebar")
            checkable: true
            checked: ViewSettings.variantsSidebar
            onToggled: ViewSettings.variantsSidebar = checked
        }
    }
    Controls.Menu {
        title: i18n("Help")
        Kirigami.Action {
            text: i18n("Unicode table")
            icon.name: "open-link-symbolic"
            onTriggered: Qt.openUrlExternally("https://symbl.cc/en/unicode-table/")
        }
        Kirigami.Action {
            text: i18n("Xkb documentation")
            icon.name: "open-link-symbolic"
            onTriggered: Qt.openUrlExternally("https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#the-xkb_symbols-section")
        }
        Kirigami.Action {
            text: i18n("Keysym table")
            icon.name: "table"
            onTriggered: keysymTable.show()
        }
        Kirigami.Action {
            text: i18n("About")
            icon.name: "help-about"
            onTriggered: about.show()
        }
    }
}
