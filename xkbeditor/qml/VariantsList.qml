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
                onClicked: {
                    bridge.file.variantIndex = listItemRoot.index;
                    forceActiveFocus();
                }
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
                    spacing: 0

                    z: contentItem.z + 1

                    Controls.Button {
                        icon.name: "edit-rename"
                        text: qsTr("Rename")
                        onClicked: {
                            // showPassiveNotification(qsTr("Renaming %1").arg(listItemRoot.title));
                            editField.visible = true;
                        }
                        icon.height: Kirigami.Units.iconSizes.small
                        visible: listItem.hovered
                        display: Controls.AbstractButton.IconOnly
                    }
                    Controls.Button {
                        icon.name: "edit-delete-remove"
                        text: qsTr("Delete")
                        onClicked: {
                            // TODO: Confirm deletion
                            deleteDialog.targetRow = listItemRoot.index
                            deleteDialog.open()
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
                onVisibleChanged: if (visible == true)
                    forceActiveFocus()
                onFocusChanged: if (focus == false)
                    visible = false
            }
        }
    }
    ListView {
        id: mainList
        model: bridge.file.variants
        delegate: delegateComponent
        clip: true
    }

    footer: Kirigami.ActionTextField {
        id: field
        placeholderText: qsTr("Add variant")
        rightActions: Kirigami.Action {
            icon.name: "document-send"
            text: field.text
            tooltip: text
            onTriggered: field.addVariant()
        }
        onAccepted: addVariant()
        function addVariant() {
            if (field.text) {
                bridge.file.variants.new(field.text);
                field.text = "";
            }
        }
    }

    Kirigami.PromptDialog {
        id: deleteDialog
        title: qsTr("Delete variant %1?").arg(id)

        property var targetVariant: mainList.model.getRow(targetRow)
        property int targetRow: -1
        property string id: if (targetVariant) { targetVariant.id } else ""
        property string name: if (targetVariant && targetVariant.name) { targetVariant.name } else id

        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

        subtitle: qsTr("Confirm deletion of variant %1").arg(name)

        onAccepted: {
            showPassiveNotification(qsTr("Deleted: %1").arg(id));
            mainList.model.remove(targetRow);
            targetRow = -1
        }
    }
}
