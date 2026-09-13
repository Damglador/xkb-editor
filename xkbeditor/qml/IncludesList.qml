pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    header: ColumnLayout {
        Kirigami.Heading {
            text: "Includes"
        }
        Kirigami.Separator {
            Layout.fillWidth: true
        }
    }
    Component {
        id: delegateComponent
        Item {
            id: listItemRoot

            required property int index
            required property var modelData
            required property var include
            property string title: include.path

            width: mainList.width - mainList.leftMargin - mainList.rightMargin
            height: listItem.implicitHeight

            Kirigami.SwipeListItem {
                id: listItem
                implicitHeight: Kirigami.Units.gridUnit * 2
                width: listItemRoot.width
                contentItem: RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
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

                    Controls.ToolButton {
                        icon.name: "edit-rename"
                        text: qsTr("Rename")
                        onClicked: showPassiveNotification(qsTr("Renaming %1").arg(listItemRoot.title))
                        icon.height: Kirigami.Units.iconSizes.small
                        visible: listItem.hovered
                        display: Controls.AbstractButton.IconOnly
                    }
                    Controls.ToolButton {
                        icon.name: "edit-delete-remove"
                        text: qsTr("Delete")
                        onClicked: {
                            showPassiveNotification(qsTr("Deleted: %1").arg(listItemRoot.title))
                            mainList.model.remove(listItemRoot.index)
                        }
                        icon.height: Kirigami.Units.iconSizes.small
                        visible: listItem.hovered
                        display: Controls.AbstractButton.IconOnly
                    }
                }
            }
        }
    }
    ListView {
        id: mainList
        model: bridge.file.variant.includes
        delegate: delegateComponent
        clip: true
    }

    footer: ColumnLayout {
        Kirigami.Separator {
            Layout.fillWidth: true
        }
        Kirigami.ActionTextField {
            id: field
            placeholderText: qsTr("Add include")
            rightActions: Kirigami.Action {
                icon.name: "document-send"
                text: field.placeholderText
                tooltip: text
                onTriggered: field.addInclude()
            }
            Layout.fillWidth: true
            onAccepted: {
                addInclude();
                focus = false;
            }
            function addInclude() {
                if (field.text) {
                    bridge.file.variant.includes.new(field.text);
                    field.text = "";
                }
            }
        }
    }
}
