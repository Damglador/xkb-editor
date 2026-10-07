pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.qmlmodels
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: keysymTableWindow
    transientParent: null // Show as a separate window in taskbar

    pageStack.initialPage: Kirigami.ScrollablePage {
        id: keysymTablePage
        globalToolBarStyle: Kirigami.ApplicationHeaderStyle.ToolBar

        actions: [
            Kirigami.Action {
                displayComponent: Kirigami.SearchField {}
            }
        ]
        header: Controls.HorizontalHeaderView {
            id: header
            syncView: table
            anchors.left: table.left
            width: keysymTablePage.width
            model: ["Name", "Keysym", "Character", "Comment"]
        }
        TableView {
            id: table
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            editTriggers: TableView.NoEditTriggers
            clip: true
            columnSpacing: 1
            rowSpacing: 1
            model: TableModel {
                TableModelColumn {
                    display: "name"
                }
                TableModelColumn {
                    display: "hex"
                }
                TableModelColumn {
                    display: "char"
                }
                TableModelColumn {
                    display: "desc"
                }

                rows: Array.from(bridge.getKeysymTable())
            }
            delegate: Controls.TableViewDelegate {
                id: cell
                padding: Kirigami.Units.mediumSpacing
                property double minWidth

                function setWidth() {
                    if (column == 0)
                        minWidth = Kirigami.Units.gridUnit * 10;
                    else if (column == 1)
                        minWidth = Kirigami.Units.gridUnit * 4;
                    else if (column == 2)
                        minWidth = Kirigami.Units.gridUnit * 4;
                    else if (column == 3)
                        minWidth = Kirigami.Units.gridUnit * 12;

                    table.setColumnWidth(column, Math.max(width, minWidth))
                    // table.setColumnWidth(3, Math.max(keysymTablePage.width - table.columnWidth(0) - table.columnWidth(1) - table.columnWidth(2), minWidth))
                }
                onWidthChanged: setWidth()
                contentItem: Kirigami.SelectableLabel {
                    text: cell.model.display ? cell.model.display : ""
                }
            }
        }
    }
}
