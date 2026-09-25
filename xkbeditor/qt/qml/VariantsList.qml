pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    header: ColumnLayout {
        Kirigami.Heading {
            text: "Variants"
        }
        Kirigami.Separator {
            Layout.fillWidth: true
        }
    }

    background: Rectangle {
        color: Kirigami.Theme.alternateBackgroundColor
    }
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
                    mainList.currentIndex = listItemRoot.index;
                    mainList.forceActiveFocus()
                }
                highlighted: listItemRoot.ListView.isCurrentItem
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

                    z: parent.contentItem.z + 1

                    Controls.Button {
                        icon.name: "edit-rename"
                        text: qsTr("Rename")
                        Controls.ToolTip.text: text
                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Kirigami.Units.toolTipDelay

                        onClicked: {
                            // showPassiveNotification(qsTr("Renaming %1").arg(listItemRoot.title));
                            popup.open();
                        }
                        icon.height: Kirigami.Units.iconSizes.small
                        visible: listItem.hovered
                        display: Controls.AbstractButton.IconOnly
                    }
                    Controls.Button {
                        icon.name: "edit-delete-remove"
                        text: qsTr("Delete")
                        Controls.ToolTip.text: text
                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Kirigami.Units.toolTipDelay

                        onClicked: bridge.removeVariant(listItemRoot.index);
                        icon.height: Kirigami.Units.iconSizes.small
                        visible: listItem.hovered
                        display: Controls.AbstractButton.IconOnly
                    }
                }
            }

            Controls.Popup {
                id: popup
                width: parent.width
                height: parent.height

                onVisibleChanged: if (visible == true)
                    editField.forceActiveFocus()

                contentItem: Kirigami.ActionTextField {
                    id: editField
                    anchors.fill: parent
                    text: listItemRoot.variant.id
                    onTextEdited: listItemRoot.variant.id = text
                    width: parent.width
                    height: parent.height
                    onAccepted: popup.close()
                }
            }
        }
    }
    ListView {
        id: mainList
        model: bridge.file.variants
        delegate: delegateComponent
        clip: true
        onCurrentIndexChanged: bridge.file.variantIndex = currentIndex
        Connections {
            target: bridge.file
            function onVariantChanged() {
                mainList.currentIndex = bridge.file.variantIndex
            }
        }
        keyNavigationEnabled: true
        highlightFollowsCurrentItem: true
    }

    footer: ColumnLayout {
        Kirigami.Separator {
            Layout.fillWidth: true
        }
        Kirigami.ActionTextField {
            id: field
            placeholderText: qsTr("Add variant")
            Layout.fillWidth: true
            rightActions: Kirigami.Action {
                icon.name: "document-send"
                text: field.placeholderText
                tooltip: text
                onTriggered: field.addVariant()
            }
            onAccepted: {
                addVariant();
                focus = false;
            }
            function addVariant() {
                if (field.text) {
                    bridge.addVariant(field.text);
                    field.text = "";
                }
            }
        }
    }

    Connections {
        target: bridge.file.variants
        function onRowsRemoved(index, first, last) {
            if (first == mainList.currentIndex) bridge.file.updateVariant()
        }
        function onRowsInserted(index, first, last) {
            if (!bridge.file.variant) bridge.file.updateVariant()
        }
    }
}
