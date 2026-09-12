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
        Layout.fillWidth: true
        model: bridge.file.variant.includes
        delegate: Controls.ItemDelegate {
            required property int index
            required property var modelData

            icon.name: "edit-delete-remove"
            width: ListView.view.width
            text: modelData.path + "(" + modelData.variant + ")"
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
