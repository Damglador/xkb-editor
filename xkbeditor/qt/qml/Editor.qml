import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import "Keyboard"

Kirigami.Page {
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

    ColumnLayout {
        id: layout
        width: keyboard.width
        anchors.centerIn: parent

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
            id: levelSelector

            Layout.alignment: Qt.AlignHCenter
            position: Controls.TabBar.Footer
            Layout.topMargin: -parent.spacing

            Repeater {
                model: [qsTr("Default"), qsTr("Shift"), qsTr("L3M"), qsTr("L3M + Shift")]
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
            parent: levelSelector
            text: qsTr("Level:")
            padding: Kirigami.Units.smallSpacing
            anchors.right: parent.left
        }

        Component {
            id: modifierBadgeComponent
            Kirigami.Badge {
                required property var modelData
                text: modelData.text
                implicitHeight: Kirigami.Units.gridUnit * 1.4
                icon.name: modelData.isGlobal ? "globe" : ""
                type: modelData.isGlobal ? Kirigami.Badge.Type.Warning : Kirigami.Badge.Type.Positive
                Controls.ToolTip.text: modelData.isGlobal ? "Set by desktop" : ""
            }
        }

        GridLayout {
            uniformCellWidths: true
            columnSpacing: Kirigami.Units.largeSpacing
            Flow {
                Layout.preferredWidth: 1
                Layout.column: 0
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                Controls.Label {
                    text: "L3M:"
                    topPadding: Kirigami.Units.smallSpacing
                    Controls.ToolTip.text: qsTr("Level 3 modifiers")
                    Controls.ToolTip.visible: hh3.hovered
                    HoverHandler {
                        id: hh3
                    }
                }
                Repeater {
                    model: bridge.file.variant.level3Mods
                    delegate: modifierBadgeComponent
                }
                Item {
                    Layout.fillWidth: true
                }
            }

            Flow {
                // visible: false
                Layout.preferredWidth: 1
                Layout.column: 1
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                Controls.Label {
                    text: qsTr("L5M:")
                    topPadding: Kirigami.Units.smallSpacing
                    Controls.ToolTip.text: qsTr("Level 5 modifiers")
                    Controls.ToolTip.visible: hh5.hovered
                    HoverHandler {
                        id: hh5
                    }
                }
                Repeater {
                    model: bridge.file.variant.level5Mods
                    delegate: modifierBadgeComponent
                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
