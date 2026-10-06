pragma ComponentBehavior: Bound

import QtQuick
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

                Connections {
                    target: bridge.file.variant
                    function onIncludesReloaded() {
                        chip.text = item.include.toString();
                    }
                }

                onClicked: chipMenu.open()
                checkable: false

                Controls.ToolTip {
                    text: item.include.available ? item.include.file : "File for this include is not available"
                    visible: chip.hovered && text && !dragHangler.active
                }

                Kirigami.AbstractCard {
                    anchors.fill: parent
                    z: parent.z - 1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: dragHangler.active ? Qt.ClosedHandCursor : Qt.ArrowCursor
                    z: parent.z - 1
                }

                Controls.Label {
                    text: "🔴"
                    anchors.right: parent.right
                    anchors.top: parent.top
                    visible: !item.include.available
                }

                down: pressed || dragHangler.active

                DragHandler {
                    id: dragHangler
                    onActiveChanged: {
                        if (active) {
                            return;
                        }
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

                IncludeMenu {
                    id: chipMenu
                    include: item.include
                    type: IncludeMenu.Type.Edit
                }

                Controls.ContextMenu.menu: Controls.Menu {
                    Controls.MenuItem {
                        text: qsTr("Copy file path")
                        icon.name: "edit-copy"
                        onTriggered: bridge.copyText(item.include.file)
                    }
                    Controls.MenuItem {
                        text: qsTr("Copy include string")
                        icon.name: "edit-copy"
                        onTriggered: bridge.copyText(item.include.toString())
                    }
                }

                onRemoved: bridge.removeInclude(item.index)
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
        IncludeMenu {
            id: addMenu
            type: IncludeMenu.Type.Add
        }
    }
}
