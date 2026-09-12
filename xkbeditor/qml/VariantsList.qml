pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    Component {
        id: delegateComponent
        Item {
            id: listItemRoot

            required property int index
            required property var modelData
            required property var variant
            property string title: variant.id

            width: mainList.width - mainList.leftMargin - mainList.rightMargin
            height: listItem.implicitHeight

            Kirigami.SwipeListItem {
                id: listItem
                implicitHeight: Kirigami.Units.gridUnit * 2
                width: listItemRoot.width
                contentItem: RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    width: listItem.width - Kirigami.Units.iconSizes.small * 2
                    Kirigami.ListItemDragHandle {
                        listItem: listItem
                        listView: mainList
                        onMoveRequested: (oldIndex, newIndex) => {
                            console.log('!!!', oldIndex, newIndex);
                            mainList.model.move(oldIndex, newIndex, 1);
                        }
                        onDropped: (oldIndex, newIndex) => {
                            console.log(">>>", oldIndex, newIndex);
                        }
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(implicitHeight, Kirigami.Units.iconSizes.small)
                        text: listItemRoot.title
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Controls.ToolButton {
                        icon.name: "edit-rename"
                        text: qsTr("Rename")
                        onClicked: {
                            showPassiveNotification(qsTr("Renaming %1").arg(listItemRoot.title));
                            editField.visible = true;
                        }
                        icon.height: Kirigami.Units.iconSizes.small
                        visible: listItem.hovered
                        display: Controls.AbstractButton.IconOnly
                    }
                    Controls.ToolButton {
                        icon.name: "edit-delete-remove"
                        text: qsTr("Delete")
                        onClicked: {
                            showPassiveNotification(qsTr("Deleted: %1").arg(listItemRoot.title));
                            mainList.model.remove(listItemRoot.index);
                        }
                        icon.height: Kirigami.Units.iconSizes.small
                        visible: listItem.hovered
                        display: Controls.AbstractButton.IconOnly
                    }
                }
            }

            Kirigami.ActionTextField {
                id: editField
                text: listItemRoot.variant.id
                onTextEdited: listItemRoot.variant.id = text
                visible: false
                width: parent.width
                height: parent.height
                onAccepted: visible = false
                onVisibleChanged: forceActiveFocus()
            }
        }
    }
    ListView {
        id: mainList
        model: bridge.file.variants
        delegate: delegateComponent
    }
}
