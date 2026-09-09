import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Item {
    width: layout.width
    height: layout.height
    ColumnLayout {
        id: layout

        RowLayout {
            Controls.Label {
                text: "Variant:"
                padding: Kirigami.Units.smallSpacing
            }
            Controls.ComboBox {
                model: bridge.variantsNames
                onActivated: bridge.currentVariant = currentIndex
            }
            Controls.Label {
                text: "File:"
            }
            Controls.TextField {
                text: bridge.openedFilePath
                padding: Kirigami.Units.smallSpacing
                Layout.fillWidth: true
            }
            Controls.Button {
                text: "Reload from file"
                display: Controls.AbstractButton.IconOnly
                icon.name: "reload"
                Controls.ToolTip.text: text
                Controls.ToolTip.visible: hovered
                onClicked: bridge.openFile(bridge.openedFilePath)
            }
        }

        Keyboard_ANSI {
            id: keyboard
            Layout.alignment: Qt.AlignHCenter
        }

        Controls.TabBar {
            id: layerSelector

            Layout.alignment: Qt.AlignHCenter
            position: Controls.TabBar.Footer
            Layout.topMargin: -parent.spacing

            Repeater {
                model: ["Default layer", "Shift layer", "RAlt layer", "Shift+RAlt layer"]
                delegate: Controls.TabButton {
                    required property var modelData
                    required property var index
                    text: index + 1
                    Controls.ToolTip.text: modelData
                    Controls.ToolTip.visible: hovered
                }
            }
        }

        Controls.Label {
            parent: layerSelector
            text: "Layer:"
            padding: Kirigami.Units.smallSpacing
            anchors.right: parent.left
        }
    }
}
