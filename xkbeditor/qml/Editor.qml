import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

ColumnLayout {
    anchors.centerIn: parent
    Controls.SpinBox {
        onValueChanged: bridge.currentVariant = value
        from: 0
        to: bridge.variantsLength
    }
    Controls.TabBar {
        id: layerSelector

        Layout.alignment: Qt.AlignHCenter
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
    }
}
