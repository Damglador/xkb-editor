import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import "Keyboard"

Item {
    width: keyboard.width
    height: layout.height
    ColumnLayout {
        id: layout

        RowLayout {
            Layout.fillWidth: true
            Controls.Label {
                text: "Flags:"
            }
            FlagsList {
                Layout.fillWidth: true
            }
        }
        RowLayout {
            Controls.Label {
                text: "Variant:"
                padding: Kirigami.Units.smallSpacing
            }
            Controls.ComboBox {
                model: bridge.file.variants
                textRole: "id"
                onActivated: bridge.file.variantIndex = currentIndex
                enabled: count != 0
            }
            Controls.Label {
                text: "Name:"
            }
            Controls.TextField {
                text: bridge.file.variant.name
                padding: Kirigami.Units.smallSpacing
                Layout.fillWidth: true
                onTextEdited: bridge.file.variant.name = text
                onAccepted: focus = false
            }
            Controls.Button {
                text: "Reload from file"
                display: Controls.AbstractButton.IconOnly
                icon.name: "reload"
                Controls.ToolTip.text: text
                Controls.ToolTip.visible: hovered
                enabled: bridge.file.path
                onClicked: bridge.file.load(bridge.file.path)
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
