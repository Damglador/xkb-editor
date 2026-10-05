pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Controls.Menu {
    id: menu
    required property int type
    property int index
    property var include

    enum Type {
        Edit,
        Add
    }

    function accept() {
        if (menu.type == IncludeMenu.Type.Add) {
            addButton.click();
        } else {
            menu.close();
        }
    }

    function action() {
        if (menu.type == IncludeMenu.Type.Add) {
            if (bridge.addInclude({
                "path": pathField.text,
                "variant": variantField.text
            })) {
                pathField.text = "";
                variantField.text = "";
                menu.close();
            }
        } else {
            bridge.removeInclude(menu.index)
        }
    }

    y: parent.height
    ColumnLayout {
        RowLayout {
            Controls.TextField {
                id: pathField
                placeholderText: qsTr("Path")
                implicitWidth: Kirigami.Units.gridUnit * 4
                text: menu.include ? menu.include.path : ""
                onTextEdited: if (menu.include) menu.include.path = text
                onAccepted: menu.accept()
                onVisibleChanged: forceActiveFocus()
            }
            Controls.TextField {
                id: variantField
                placeholderText: qsTr("Variant")
                implicitWidth: Kirigami.Units.gridUnit * 4
                text: (menu.include && menu.include.variant) ? menu.include.variant : ""
                onTextEdited: if (menu.include) menu.include.variant = text
                onAccepted: menu.accept()
            }
        }
        Controls.Button {
            id: removeButton
            visible: menu.type == IncludeMenu.Type.Edit
            Layout.fillWidth: true
            icon.name: "edit-delete-remove"
            text: qsTr("Remove include")
            onClicked: menu.action()
        }
        Controls.Button {
            id: addButton
            visible: menu.type == IncludeMenu.Type.Add
            Layout.fillWidth: true
            icon.name: "add"
            text: qsTr("Add include")
            onClicked: menu.action()
        }
    }
    onClosed: bridge.file.variant.reloadIncludes()
}
