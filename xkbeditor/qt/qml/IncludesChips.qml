pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Flow {
    id: flow
    spacing: Kirigami.Units.smallSpacing
    Repeater {
        id: repeater
        model: bridge.file.variant ? bridge.file.variant.includes : []
        delegate: Item {
            id: item
            required property int index
            required property var include

            width: chip.implicitWidth
            height: chip.implicitHeight
            z: dragHangler.active ? 100 : 0

            Kirigami.Chip {
                id: chip

                text: item.include.toString()

                onClicked: chipMenu.open()
                closable: false
                checkable: false

                Kirigami.AbstractCard {
                    anchors.fill: parent
                    z: parent.z - 1
                }

                DragHandler {
                    id: dragHangler
                    cursorShape: Qt.CursorShape.ClosedHandCursor
                    onActiveChanged: {
                        if (active)
                            return;
                        const p = chip.mapToItem(flow, chip.width / 2, chip.height / 2);
                        const target = flow.childAt(p.x, p.y);

                        if (target && (target != item) && target != addButton)
                            repeater.model.move(item.index, target.index);

                        chip.x = 0;
                        chip.y = 0;
                    }

                    // Without -1 it wiggles a bit
                    // -Kirigami.Units.smallSpacing is for spacing before addButton
                    yAxis.minimum: -item.y
                    xAxis.minimum: -item.x
                    yAxis.maximum: flow.implicitHeight - item.y - item.height - 1
                    xAxis.maximum: flow.implicitWidth - item.x - item.width - 1 - addButton.width - Kirigami.Units.smallSpacing
                }

                Controls.Menu {
                    id: chipMenu
                    y: parent.height
                    ColumnLayout {
                        RowLayout {
                            Controls.TextField {
                                placeholderText: qsTr("Path")
                                implicitWidth: Kirigami.Units.gridUnit * 4
                                text: item.include.path
                                onTextEdited: item.include.path = text
                                onAccepted: chipMenu.close()
                                onVisibleChanged: forceActiveFocus()
                            }
                            Controls.TextField {
                                placeholderText: qsTr("Variant")
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
                            text: qsTr("Remove include")
                            onClicked: bridge.removeInclude(item.index)
                        }
                    }
                    onClosed: bridge.file.variant.reloadIncludes()
                }
            }
        }
    }

    Controls.Button {
        id: addButton
        text: qsTr("Add include")
        icon.name: "add"
        display: Controls.AbstractButton.IconOnly
        implicitHeight: Kirigami.Units.gridUnit * 1.6
        enabled: bridge.file.variant

        Controls.ToolTip {
            visible: addButton.hovered
            text: addButton.text
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
                        placeholderText: qsTr("Path")
                        implicitWidth: Kirigami.Units.gridUnit * 4
                        onAccepted: addMenu_Button.click()
                        onVisibleChanged: forceActiveFocus()
                    }
                    Controls.TextField {
                        id: addMenu_VariantField
                        placeholderText: qsTr("Variant")
                        implicitWidth: Kirigami.Units.gridUnit * 4
                        onAccepted: addMenu_Button.click()
                    }
                }
                Controls.Button {
                    id: addMenu_Button
                    Layout.fillWidth: true
                    icon.name: "add"
                    text: qsTr("Add include")
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
