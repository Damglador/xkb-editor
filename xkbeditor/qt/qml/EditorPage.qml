pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import Settings as AppSettings
import "Preview"

Kirigami.Page {
    id: page
    required property var file
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    padding: 0

    Controls.SplitView {
        anchors.fill: parent
        VariantsList {
            id: variantsList
            file: page.file

            visible: AppSettings.View.variantsSidebar
            Controls.SplitView.preferredWidth: Kirigami.Units.gridUnit * 12
            Controls.SplitView.maximumWidth: page.width / 2
            Controls.SplitView.minimumWidth: Kirigami.Units.gridUnit * 7
            z: editorView.z + 1
        }
        Item {
            id: editorView
            Controls.StackView {
                id: stackView
                initialItem: editorComponent
                anchors.fill: parent
            }
            Controls.ToolButton {
                id: preview
                text: qsTr("Preview")
                icon.name: "preview"
                checkable: true
                anchors.top: parent.top
                anchors.right: parent.right
                onToggled: {
                    if (checked) {
                        stackView.replaceCurrentItem(previewComponent);
                    } else {
                        stackView.replaceCurrentItem(editorComponent);
                    }
                }
            }
        }
        Component.onCompleted: restoreState(settings.splitView)
        Component.onDestruction: settings.splitView = saveState()
    }

    Component {
        id: editorComponent
        Editor {
            variant: page.file.variant
        }
    }

    Component {
        id: previewComponent
        Item {
            PreviewKeyboard {
                variant: page.file.variant
                anchors.centerIn: parent
                implicitHeight: childrenRect.height
                implicitWidth: childrenRect.width
            }
        }
    }

    Settings {
        id: settings
        category: "Editor"
        location: AppSettings.Paths.stateFile
        property var splitView
    }
}
