pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import xkbeditor

Kirigami.Dialog {
    id: importDialog
    title: qsTr("Import variants")
    preferredWidth: Kirigami.Units.gridUnit * 20
    standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
    onAccepted: {
        for (let i = 0; i < file.variants.rowCount(); i++) {
            let variant = file.variants.get(i)
            if (variant.checked) {
                bridge.file.variants.append(variant);
                bridge.notify(qsTr("Imported %1").arg(variant.id));
            }
        }
    }

    ListView {
        id: listView
        model: file.variants
        delegate: listItemDelegate
    }

    function load(filePath) {
        file.load(filePath)
    }

    SymbolsFile {
        id: file
    }

    Connections {
        target: file
        function onError(message) {
            bridge.error(message)
        }
        function onFileLoaded() {
            importDialog.open()
        }
    }

    Component {
        id: listItemDelegate
        Controls.CheckDelegate {
            id: listItem
            required property var modelData
            required property var variant
            text: variant.id
            width: listView.width - listView.leftMargin - listView.rightMargin
            checked: variant.checked
            onClicked: variant.checked = checked
        }
    }
}
