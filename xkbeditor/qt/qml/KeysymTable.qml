pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kitemmodels
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
                text: copyrightSheet.title
                icon.name: "text-x-copying"
                displayHint: Kirigami.DisplayHint.IconOnly
                onTriggered: copyrightSheet.open()
            },
            Kirigami.Action {
                text: docSheet.title
                icon.name: "help-about"
                displayHint: Kirigami.DisplayHint.IconOnly
                onTriggered: docSheet.open()
            },
            Kirigami.Action {
                displayComponent: Kirigami.SearchField {
                    id: searchField
                    onTextChanged: proxyModel.filterString = text
                }
            },
            Kirigami.Action {
                text: "Match case"
                icon.name: "format-text-superscript"
                displayHint: Kirigami.DisplayHint.IconOnly
                checkable: true
                checked: proxyModel.filterCaseSensitivity == Qt.CaseSensitive

                tooltip: text

                onCheckedChanged: checked => {
                    if (checked)
                        proxyModel.filterCaseSensitivity = Qt.CaseSensitive;
                    else
                        proxyModel.filterCaseSensitivity = Qt.CaseInsensitive;
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

    Kirigami.OverlaySheet {
        id: copyrightSheet
        title: qsTr("Copyright for keysymdef.h")
        Kirigami.SelectableLabel {
            Layout.fillWidth: true
            padding: Kirigami.Units.largeSpacing
            wrapMode: Text.WordWrap
            text: proxyModel.sourceModel.getCopyright()
        }
    }
    Kirigami.OverlaySheet {
        id: docSheet
        title: qsTr("About keysymdef.h")
        ColumnLayout {
            width: docSheet.width
            Kirigami.SelectableLabel {
                Layout.fillWidth: true
                padding: Kirigami.Units.largeSpacing
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                text: qsTr(
`Information in this table, copyright as well as the section below are parsed
from /usr/include/X11/keysymdef.h or pre-packaged keysymdef.h,
if one is not available on your system.

Current source: %1`).arg(proxyModel.sourceModel.getSourcePath())
            }
            Kirigami.Separator {
                Layout.fillWidth: true
            }
            Kirigami.SelectableLabel {
                padding: Kirigami.Units.largeSpacing
                wrapMode: Text.WordWrap
                text: proxyModel.sourceModel.getDoc()
            }
        }
    }
}
