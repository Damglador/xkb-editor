pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Flow {
    spacing: Kirigami.Units.smallSpacing
    Repeater {
        id: repeater
        model: bridge.file.variant ? bridge.file.variant.includes : []
        delegate: Kirigami.Chip {
            id: item
            required property int index
            required property var include

            text: include.variant ? include.path + "(" + include.variant + ")" : include.path

            onClicked: chipMenu.open()
            closable: false
            checkable: false

            Controls.Menu {
                id: chipMenu
                y: parent.height
                ColumnLayout {
                    RowLayout {
                        Controls.TextField {
                            placeholderText: "Path"
                            implicitWidth: Kirigami.Units.gridUnit * 4
                            text: item.include.path
                            onTextEdited: item.include.path = text
                            onAccepted: chipMenu.close()
                        }
                        Controls.TextField {
                            placeholderText: "Variant"
                            implicitWidth: Kirigami.Units.gridUnit * 4
                            text: item.include.variant ? item.include.variant : ""
                            onTextEdited: item.include.variant = text
                            onAccepted: chipMenu.close()
                        }
                    }
                    Controls.Button {
                        id: removeButton
                        Layout.fillWidth: true
                        icon.name: "edit-delete-remove"
                        text: "Remove include"
                        onClicked: bridge.removeInclude(item.index);
                    }
                }
                onClosed: bridge.file.variant.reloadIncludes()
            }
        }
    }

    Controls.Button {
        id: button
        text: "Add include"
        icon.name: "add"
        display: Controls.AbstractButton.IconOnly
        implicitHeight: Kirigami.Units.gridUnit * 1.6
        enabled: bridge.file.variant

        Controls.ToolTip {
            visible: button.hovered
            text: button.text
            delay: Kirigami.Units.toolTipDelay
        }

        onClicked: addMenu.open()
        Controls.Menu {
            id: addMenu
            y: parent.height
            ColumnLayout {
                RowLayout {
                    Controls.TextField {
                        id: addMenu_PathField
                        placeholderText: "Path"
                        implicitWidth: Kirigami.Units.gridUnit * 4
                        onAccepted: addMenu_Button.click()
                    }
                    Controls.TextField {
                        id: addMenu_VariantField
                        placeholderText: "Variant"
                        implicitWidth: Kirigami.Units.gridUnit * 4
                        onAccepted: addMenu_Button.click()
                    }
                }
                Controls.Button {
                    id: addMenu_Button
                    Layout.fillWidth: true
                    icon.name: "add"
                    text: "Add include"
                    onClicked: {
                        if (bridge.addInclude({
                            "path": addMenu_PathField.text,
                            "variant": addMenu_VariantField.text
                        })) {
                            addMenu_PathField.text = "";
                            addMenu_VariantField.text = "";
                            addMenu.close();
                        }
                    }
                }
            }
        }
    }
}
