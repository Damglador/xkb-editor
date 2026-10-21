import QtCore
import QtQuick
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import Settings as AppSettings

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
        Editor {
            id: editorView
            variant: page.file.variant
        }
        Component.onCompleted: restoreState(settings.splitView)
        Component.onDestruction: settings.splitView = saveState()
    }

    Settings {
        id: settings
        category: "Editor"
        location: AppSettings.Paths.stateFile
        property var splitView
    }
}
