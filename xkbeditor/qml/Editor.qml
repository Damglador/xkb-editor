import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Item {
    anchors.fill: parent

    RowLayout {
        anchors.bottom: keyboard.top
        anchors.left: keyboard.left

        Controls.SpinBox {
            onValueChanged: bridge.currentVariant = value
            from: 0
            to: bridge.variantsLength
        }
        Kirigami.SelectableLabel {
            text: bridge.variantName
        }
    }
    Controls.Label {
        text: "Layer:"
        padding: Kirigami.Units.smallSpacing
        anchors.right: layerSelector.left
        anchors.verticalCenter: layerSelector.verticalCenter
    }
    Controls.TabBar {
        id: layerSelector

        anchors.bottom: keyboard.top
        anchors.horizontalCenter: keyboard.horizontalCenter

        Controls.TabButton {
            text: "1"
            Controls.ToolTip.text: "Default layer"
            Controls.ToolTip.visible: hovered
        }
        Controls.TabButton {
            text: "2"
            Controls.ToolTip.text: "Shift layer"
            Controls.ToolTip.visible: hovered
        }
        Controls.TabButton {
            text: "3"
            Controls.ToolTip.text: "RAlt layer"
            Controls.ToolTip.visible: hovered
        }
        Controls.TabButton {
            text: "4"
            Controls.ToolTip.text: "Shift+RAlt layer"
            Controls.ToolTip.visible: hovered
        }
    }

    Keyboard_US {
        id: keyboard
        anchors.centerIn: parent
    }
}
