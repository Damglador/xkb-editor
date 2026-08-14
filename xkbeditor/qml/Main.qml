import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import project

Kirigami.ApplicationWindow {
    id: root

    title: qsTr("Simple Markdown viewer")

    minimumWidth: Kirigami.Units.gridUnit * 60
    minimumHeight: Kirigami.Units.gridUnit * 20
    width: minimumWidth
    height: minimumHeight

    pageStack.initialPage: initPage

    Component {
        id: initPage

        Kirigami.Page {
            Keyboard_US {}

            Bridge {
                id: bridge
            }
        }
    }
}
