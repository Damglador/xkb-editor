import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Item {
    RowLayout {
        anchors.bottom: keyboard.top
        anchors.left: keyboard.left
        anchors.margins: Kirigami.Units.smallSpacing

        Controls.Label {
            text: "Variant:"
            padding: Kirigami.Units.smallSpacing
        }
        Controls.ComboBox {
            model: bridge.variantsNames
            onActivated: bridge.currentVariant = currentIndex
        }
    }

    Controls.Label {
        text: "Layer:"
        padding: Kirigami.Units.smallSpacing
        anchors.right: layerSelector.left
        anchors.verticalCenter: layerSelector.verticalCenter
    }
    RowLayout {
        id: layerSelector

        property var currentIndex: 0

        anchors.top: keyboard.bottom
        anchors.horizontalCenter: keyboard.horizontalCenter
        anchors.margins: Kirigami.Units.smallSpacing

        Repeater {
            model: ["Default layer", "Shift layer", "RAlt layer", "Shift+RAlt layer"]
            delegate: Controls.RoundButton {
                required property var modelData
                required property var index
                text: index + 1
                Controls.ToolTip.text: modelData
                Controls.ToolTip.visible: hovered

                checked: layerSelector.currentIndex == index
                highlighted: layerSelector.currentIndex == index
                onClicked: layerSelector.currentIndex = index
            }
        }
    }

    Keyboard_US {
        id: keyboard
        anchors.centerIn: parent
    }
}
