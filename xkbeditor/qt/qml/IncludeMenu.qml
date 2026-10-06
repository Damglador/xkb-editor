pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Controls.Menu {
    id: menu
    required property int type
    property var include

    enum Type {
        Edit,
        Add
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
            if (menu.include) {
                menu.include.path = pathField.text;
                menu.include.variant = variantField.text;
                bridge.file.variant.reloadIncludes();
            }
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
                onAccepted: menu.action()
                onVisibleChanged: forceActiveFocus()
            }
            Controls.TextField {
                id: variantField
                placeholderText: qsTr("Variant")
                implicitWidth: Kirigami.Units.gridUnit * 4
                text: (menu.include && menu.include.variant) ? menu.include.variant : ""
                onAccepted: menu.action()
            }
        }
        Controls.Button {
            id: removeButton
            visible: menu.type == IncludeMenu.Type.Edit
            Layout.fillWidth: true
            icon.name: "dialog-ok"
            text: qsTr("Confirm")
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
}
