pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Flow {
    spacing: Kirigami.Units.smallSpacing
    Repeater {
        id: repeater
        model: root.variant ? root.variant.flags : []
        delegate: Kirigami.Chip {
            required property int index
            required property var modelData

            text: modelData

            onRemoved: undoStack.removeFlag(root.variant, modelData)
        }
    }
    Controls.Button {
        id: button
        text: qsTr("Add flag")
        icon.name: "add"
        display: Controls.AbstractButton.IconOnly
        implicitHeight: Kirigami.Units.gridUnit * 1.6
        enabled: list.count != 0

        Controls.ToolTip {
            visible: button.hovered
            text: button.text
            delay: Kirigami.Units.toolTipDelay
        }

        onClicked: menu.open()
        Controls.Menu {
            id: menu
            y: parent.height
            Repeater {
                id: list
                model: root.variant ? root.variant.availableFlags : []
                delegate: Controls.MenuItem {
                    required property var modelData
                    text: modelData
                    onClicked: {
                        undoStack.addFlag(root.variant, modelData);
                        menu.close();
                    }
                }
            }
        }
    }
}
