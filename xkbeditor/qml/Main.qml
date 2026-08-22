import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import project

Kirigami.ApplicationWindow {
    id: window

    title: qsTr("XkbEditor")

    minimumWidth: Kirigami.Units.gridUnit * 60
    minimumHeight: Kirigami.Units.gridUnit * 20
    width: minimumWidth
    height: minimumHeight

    pageStack.initialPage: initPage

    Bridge {
        id: bridge
    }

    Component {
        id: initPage

        Kirigami.Page {
            Editor {}
        }
    }
}
