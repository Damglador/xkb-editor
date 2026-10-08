from PySide6.QtCore import (
    QAbstractTableModel,
    QModelIndex,
    QPersistentModelIndex,
    Qt,
    Slot,
)
from PySide6.QtQml import QmlElement

from xkbeditor.globals import KEYSYMDEF_PATH
from xkbeditor.parser.keysymdef import getTableFromFile

QML_IMPORT_NAME = "xkbeditor"
QML_IMPORT_MAJOR_VERSION = 2

@QmlElement
class KeysymTableModel(QAbstractTableModel):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = getTableFromFile(KEYSYMDEF_PATH)
        self.copyright = ""
        self.doc = ""
        if not self._items[0].get("name"):
            self.copyright = self._items.pop(0).get("desc")
        if not self._items[0].get("name"):
            string: str = self._items.pop(0).get("desc")
            self.doc = "\n".join([line.strip(" *") for line in string.split("\n")])

    @Slot(result=str)
    def getCopyright(self):
        return self.copyright

    @Slot(result=str)
    def getDoc(self):
        return self.doc

    @Slot(result=str)
    def getSourcePath(self):
        return KEYSYMDEF_PATH

    def rowCount(self, /, parent=QModelIndex) -> int:
        return len(self._items)

    def columnCount(self, /, parent=QModelIndex) -> int:
        return 4

    def data(self, index: QModelIndex | QPersistentModelIndex, role: int=Qt.ItemDataRole.DisplayRole):
        if not index.isValid(): return

        row = index.row()
        column = index.column()
        item = self._items[row]

        if role == Qt.ItemDataRole.DisplayRole:
            match column:
                case 0: return item.get("name")
                case 1: return item.get("hex")
                case 2: return item.get("char") or ""
                case 3: return item.get("desc") or ""

    def __iter__(self):
        return iter(self._items)

    def headerData(self, section: int, orientation: Qt.Orientation, /, role: int=Qt.ItemDataRole.DisplayRole):
        if orientation == Qt.Orientation.Horizontal:
            match section:
                case 0: return "Name"
                case 1: return "Keysym"
                case 2: return "Character"
                case 3: return "Comment"
