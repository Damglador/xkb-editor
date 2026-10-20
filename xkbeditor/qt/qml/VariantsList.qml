pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: root
    property var file

    header: ColumnLayout {
        RowLayout {
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Kirigami.Heading {
                text: qsTr("Variants")
            }
            Item {
                Layout.fillWidth: true
            }
            Controls.Button {
                text: enabled ? qsTr("Reload from opened file") : qsTr("No file path to load from")
                display: Controls.AbstractButton.IconOnly
                icon.name: "reload"
                Controls.ToolTip.text: text
                Controls.ToolTip.visible: hovered
                enabled: root.file.path
                onClicked: root.file.load(root.file.path)
            }
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

            Controls.ItemDelegate {
                id: listItem
                implicitHeight: Kirigami.Units.gridUnit * 2
                anchors.fill: listItemRoot
                // Padding begone!
                topInset: 0
                bottomInset: 0
                topPadding: 0
                bottomPadding: 0

                onClicked: {
                    mainList.currentIndex = listItemRoot.index;
                    mainList.forceActiveFocus()
                }
                highlighted: listItemRoot.ListView.isCurrentItem
                contentItem: RowLayout {
                    width: listItem.width - Kirigami.Units.iconSizes.small * 2
                    Kirigami.ListItemDragHandle {
                        listItem: listItem
                        listView: mainList
                        onMoveRequested: (oldIndex, newIndex) => {
                            // console.log('!!!', oldIndex, newIndex);
                            undoStack.moveElement(mainList.model, oldIndex, newIndex);
                        }
                        // onDropped: (oldIndex, newIndex) => {
                        //     console.log(">>>", oldIndex, newIndex);
                        // }
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        text: listItemRoot.title
                    }
                }
                RowLayout {
                    anchors.right: listItem.right
                    anchors.rightMargin: Kirigami.Units.smallSpacing
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    z: parent.z + 1
                    visible: listItem.hovered

                    Controls.Button {
                        icon.name: "edit-rename"
                        text: qsTr("Rename")
                        Controls.ToolTip.text: text
                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Kirigami.Units.toolTipDelay

                        onClicked: popup.open();
                        icon.height: Kirigami.Units.iconSizes.small
                        display: Controls.AbstractButton.IconOnly
                    }
                    Controls.Button {
                        icon.name: "edit-delete-remove"
                        text: qsTr("Delete")
                        Controls.ToolTip.text: text
                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: Kirigami.Units.toolTipDelay

                        onClicked: undoStack.removeVariant(root.file.variants, listItemRoot.index);
                        icon.height: Kirigami.Units.iconSizes.small
                        display: Controls.AbstractButton.IconOnly
                    }
                }
            }

            Controls.Popup {
                id: popup
                width: parent.width
                height: parent.height

                onVisibleChanged: {
                    if (visible == true) {
                        editField.forceActiveFocus()
                    } else {
                        undoStack.editText(root.file.variants.get(listItemRoot.index), "id", editField.text)
                    }
                }

                contentItem: Kirigami.ActionTextField {
                    id: editField
                    anchors.fill: parent
                    text: listItemRoot.variant.id
                    width: parent.width
                    height: parent.height
                    onAccepted: popup.close()
                }
            }
        }
    }
    ListView {
        id: mainList
        model: root.file.variants
        delegate: delegateComponent
        clip: true
        onCurrentIndexChanged: root.file.variantIndex = currentIndex
        Connections {
            target: root.file
            function onVariantChanged() {
                mainList.currentIndex = root.file.variantIndex
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
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
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
                    undoStack.addVariant(root.file.variants, field.text);
                    field.text = "";
                }
            }
        }
    }

    Connections {
        target: root.file.variants
        function onRowsRemoved(index, first, last) {
            if (first == mainList.currentIndex) root.file.updateVariant()
        }
        function onRowsInserted(index, first, last) {
            if (!root.file.variant) root.file.updateVariant()
        }
    }
}
