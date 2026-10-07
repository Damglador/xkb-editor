pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kitemmodels
import Qt.labs.qmlmodels
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import xkbeditor

Kirigami.ApplicationWindow {
    title: keysymTablePage.title
    transientParent: null // Show as a separate window in taskbar
    width: Kirigami.Units.gridUnit * 36

    pageStack.initialPage: Kirigami.ScrollablePage {
        id: keysymTablePage
        title: qsTr("Keysym table")
        globalToolBarStyle: Kirigami.ApplicationHeaderStyle.ToolBar

        actions: [
            Kirigami.Action {
                displayComponent: Kirigami.SearchField {
                    id: searchField
                    onTextChanged: proxyModel.filterString = text
                }
            },
            Kirigami.Action {
                displayComponent: Controls.ToolButton {
                    text: "Match case"
                    icon.name: "format-text-superscript"
                    display: Controls.AbstractButton.Display.IconOnly
                    checkable: true
                    checked: proxyModel.filterCaseSensitivity == Qt.CaseSensitive

                    Controls.ToolTip.text: text
                    Controls.ToolTip.visible: hovered

                    onCheckedChanged: {
                        if (checked)
                            proxyModel.filterCaseSensitivity = Qt.CaseSensitive;
                        else
                            proxyModel.filterCaseSensitivity = Qt.CaseInsensitive;
                    }
                }
            }
        ]
        header: Controls.HorizontalHeaderView {
            id: header
            syncView: table
            anchors.left: table.left
            width: keysymTablePage.width
        }

        KSortFilterProxyModel {
            id: proxyModel
            sourceModel: KeysymTableModel {}
            filterCaseSensitivity: Qt.CaseInsensitive
            filterKeyColumn: -1
        }
        TableView {
            id: table
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            editTriggers: TableView.NoEditTriggers
            clip: true
            columnSpacing: 1
            rowSpacing: 1
            model: proxyModel
            delegate: Controls.TableViewDelegate {
                id: cell
                padding: Kirigami.Units.mediumSpacing
                property double minWidth

                function setWidth() {
                    if (column == 0)
                        minWidth = Kirigami.Units.gridUnit * 10;
                    else if (column == 1)
                        minWidth = Kirigami.Units.gridUnit * 5;
                    else if (column == 2)
                        minWidth = Kirigami.Units.gridUnit * 4;
                    else if (column == 3)
                        minWidth = Kirigami.Units.gridUnit * 15;

                    table.setColumnWidth(column, Math.max(width, minWidth));
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
