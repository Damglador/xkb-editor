pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Kirigami.Card {
    header: ColumnLayout {
        Kirigami.Heading {
            text: "Includes"
        }
        Kirigami.Separator {
            Layout.fillWidth: true
        }
    }
    contentItem: ListView {
        id: listView
        Layout.fillWidth: true
        model: bridge.file.variant.includes
        delegate: Controls.ItemDelegate {
            required property int index
            required property var include

            icon.name: "edit-delete-remove"
            width: ListView.view.width
            text: include.path + "(" + include.variant + ")"
            onClicked: listView.model.remove(index)
        }
        clip: true
    }

    footer: RowLayout {
        Controls.Label {
            text: qsTr("Add:")
        }
        Controls.TextField {
            placeholderText: qsTr("us(basic)")

            implicitWidth: Kirigami.Units.gridUnit * 8

            onAccepted: {
                if (text != "") {
                    // bridge.addInclude(text);
                    text = "";
                }
            }
        }
    }
}
