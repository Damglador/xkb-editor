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

    pageStack.initialPage: initPage

    Bridge {
        id: bridge
    }

    menuBar: MenuBar {}

    Component {
        id: initPage
        Kirigami.Page {
            globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
            RowLayout {
                anchors.centerIn: parent
                // Kirigami.AbstractCard {
                //     implicitWidth: Kirigami.Units.gridUnit * 10
                //     Layout.fillWidth: true
                //     Layout.fillHeight: true
                //     contentItem: IncludesList { }
                // }
                Editor {
                    Component.onCompleted: bridge.loadTestVariant()
                }
            }
        }
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

    Connections {
        target: bridge
        function onError(str) {
            statusBarLabel.setError(str);
        }
    }

    globalDrawer: Kirigami.GlobalDrawer {
        id: variantsDrawer
        modal: false
        drawerOpen: Settings.View.variantsSidebar
        Connections {
            target: Settings.View
            function onVariantsSidebarChanged() {
                variantsDrawer.drawerOpen = Settings.View.variantsSidebar;
            }
        }

        interactiveResizeEnabled: true

        contentItem: VariantsList {
            id: content
            anchors.fill: parent
            anchors.margins: 0
        }

        preferredSize: Kirigami.Units.gridUnit * 12
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
        onVisibleChanged: if (visible == true)
            timeout.start()

        contentItem: RowLayout {
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
}
