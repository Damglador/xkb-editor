pragma Translator: "Variant Editor"

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
                text: qsTr("Flags:")
            }
            FlagsChips {
                Layout.fillWidth: true
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Controls.Label {
                text: qsTr("Includes:")
            }
            IncludesChips {
                Layout.fillWidth: true
            }
        }
        RowLayout {
            Controls.Label {
                text: qsTr("Variant:")
            }
            Controls.ComboBox {
                id: variantComboBox
                model: bridge.file.variants
                textRole: "id"
                onActivated: bridge.file.variantIndex = currentIndex
                enabled: count != 0
                Connections {
                    target: bridge.file
                    function onVariantChanged() {
                        variantComboBox.currentIndex = bridge.file.variantIndex;
                    }
                }
            }
            Controls.Label {
                text: qsTr("Name:")
            }
            Controls.TextField {
                enabled: bridge.file.variant
                text: bridge.file.variant ? bridge.file.variant.name : ""
                onTextEdited: bridge.file.variant.name = text

                Layout.fillWidth: true
                onAccepted: focus = false
            }
        }

        Keyboard_ANSI {
            id: keyboard
            Layout.alignment: Qt.AlignHCenter

            Controls.Popup {
                anchors.centerIn: parent
                visible: !bridge.file.variant
                closePolicy: Controls.Popup.NoAutoClose
                Controls.Label {
                    text: qsTr("No variant to edit")
                }
            }
        }

        Controls.TabBar {
            id: layerSelector

            Layout.alignment: Qt.AlignHCenter
            position: Controls.TabBar.Footer
            Layout.topMargin: -parent.spacing

            Repeater {
                model: [qsTr("Default"), qsTr("Shift"), qsTr("Right Alt"), qsTr("Shift+Right Alt")]
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
            text: qsTr("Layer:")
            padding: Kirigami.Units.smallSpacing
            anchors.right: parent.left
        }
    }
}
