import re
from enum import Enum, auto
from urllib.parse import urlparse

from PySide6.QtCore import (
    Property,
    QAbstractListModel,
    QEnum,
    QModelIndex,
    QObject,
    QPersistentModelIndex,
    Qt,
    Signal,
    Slot,
)

from . import xkb
from .getchar import getchar


@QEnum
class XkbFlag(Enum):
    DEFAULT = auto()
    PARTIAL = auto()
    HIDDEN = auto()
    ALPHANUMERIC_KEYS = auto()
    MODIFIER_KEYS = auto()
    KEYPAD_KEYS = auto()
    FUNCTION_KEYS = auto()
    ALTERNATE_GROUP = auto()

class List(QAbstractListModel):
    ObjectRole = Qt.ItemDataRole.UserRole + 1

    def __init__(self, items: list | None = None, parent=None):
        super().__init__(parent=parent)
        self._items = items or []

    def initialize(self, items):
        self._items = items

    def rowCount(self, /, parent=QModelIndex) -> int:
        return len(self._items)

    def setData(self, index, value, /, role=Qt.ItemDataRole.EditRole) -> bool:
        if role == Qt.ItemDataRole.EditRole:
            self._items[index.row()]=value
            self.dataChanged.emit(index, index);
            return True
        return False

    def data(self, index: QModelIndex | QPersistentModelIndex, role: int=Qt.ItemDataRole.DisplayRole):
        if not index.isValid() or not 0 <= index.row() < self.rowCount():
            return
        return self._items[index.row()]

    def roleNames(self) -> dict:
        return {self.ObjectRole: b"modelData"}

    @Slot(int)
    def remove(self, row: int):
        if not 0 <= row < self.rowCount():
            return

        self.beginRemoveRows(QModelIndex(), row, row)
        del self._items[row]
        self.endRemoveRows()

    @Slot(int, int)
    @Slot(int, int, int) # For compatability with ListModel.move()
    def move(self, oldIndex, newIndex, n = 1):
        if not (0 <= oldIndex < self.rowCount()) or not (0 <= newIndex < self.rowCount()):
            return

        if newIndex < oldIndex:
            dest = newIndex
        else:
            dest = newIndex + 1

        self.beginMoveRows(QModelIndex(), oldIndex, oldIndex, QModelIndex(), dest)
        self._items[newIndex], self._items[oldIndex] = self._items[oldIndex], self._items[newIndex]
        self.endMoveRows()

    @Slot()
    def reset(self):
        self.beginResetModel()
        self._items = []
        self.endResetModel()

    def __iter__(self):
        return iter(self._items)

class FlagsList(List):
    def __init__(self, items: list[xkb.Flags], parent=None):
        super().__init__(items, parent=parent)

class IncludesList(List):
    PathRole = Qt.ItemDataRole.UserRole + 2
    VariantRole = Qt.ItemDataRole.UserRole + 3

    def __init__(self, items: list[xkb.Include], parent=None):
        super().__init__(parent=parent)
        self._items = items

    def roleNames(self) -> dict:
        return {
            self.ObjectRole: b"include",
            self.PathRole: b"path",
            self.VariantRole: b"variant"
        }

    def data(self, index: QModelIndex | QPersistentModelIndex, role: int=Qt.ItemDataRole.DisplayRole):
        if not index.isValid() or not 0 <= index.row() < self.rowCount():
            return
        match(role):
            case self.ObjectRole:
                return Include(self._items[index.row()])
            case self.PathRole:
                return self._items[index.row()].path
            case self.VariantRole:
                return self._items[index.row()].variant

    @Slot(str)
    def new(self, str: str = ""):
        self.beginInsertRows(QModelIndex(), len(self._items), len(self._items))
        self._items.append(xkb.Include(path=str))
        self.endInsertRows()


class VariantsList(List):
    IdRole = Qt.ItemDataRole.UserRole + 2
    NameRole = Qt.ItemDataRole.UserRole + 3

    def __init__(self, items: list[xkb.Variant], parent=None):
        super().__init__(parent=parent)
        self._items = items

    def roleNames(self) -> dict:
        return {
            self.ObjectRole: b"variant",
            self.IdRole: b"id",
            self.NameRole: b"name",
        }

    def data(self, index: QModelIndex | QPersistentModelIndex, role: int=Qt.ItemDataRole.DisplayRole):
        if not index.isValid() or not 0 <= index.row() < self.rowCount():
            return
        match(role):
            case self.ObjectRole:
                return Variant(self._items[index.row()], parent=self)
            case self.IdRole:
                return self._items[index.row()].id
            case self.NameRole:
                return self._items[index.row()].name

    def setItems(self, items: list[xkb.Variant]):
        self.beginResetModel()
        self._items = items
        self.endResetModel()

    @Slot(int, result=QObject)
    def getRow(self, row: int):
        if 0 <= row < len(self._items):
            return Variant(self._items[row], parent=self)

    @Slot()
    @Slot(str)
    def new(self, id: str = ""):
        self.beginInsertRows(QModelIndex(), len(self._items), len(self._items))
        self._items.append(xkb.Variant(id=id))
        self.endInsertRows()

class Include(QObject):
    def __init__(self, include: xkb.Include, parent=None):
        super().__init__(parent)
        self._include = include

    pathChanged = Signal()
    @Property(str, notify=pathChanged)
    def path(self): return self._include.path

    @path.setter
    def path(self, str): self._include.path = str

    variantChanged = Signal()
    @Property(str, notify=variantChanged)
    def variant(self): return self._include.variant

    @variant.setter
    def variant(self, str): self._include.variant = str


# pyright: reportRedeclaration=false
class Variant(QObject):
    def __init__(self, variant: xkb.Variant | None = None, parent=None):
        super().__init__(parent)
        if variant is None:
            self._variant = xkb.Variant()
        else:
            self._variant = variant

        self._includes = IncludesList(self._variant.includes, parent=self)

    idChanged = Signal()
    @Property(str, notify=idChanged)
    def id(self): return self._variant.id

    @id.setter
    def id(self, str):
        self._variant.id = str
        self.idChanged.emit()

    nameChanged = Signal()
    @Property(str, notify=nameChanged)
    def name(self): return self._variant.name

    @name.setter
    def name(self, str):
        self._variant.name = str
        self.nameChanged.emit()

    flagsChanged = Signal()
    @Property(list, notify=flagsChanged)
    def flags(self):
        return [flag.name for flag in self._variant.flags]

    includesChanged = Signal()
    @Property(QObject, notify=includesChanged)
    def includes(self):
        return self._includes

    @Slot(str, int, result=str)
    def getSymbol(self, keycode: str, layer: int) -> str:
        return self._variant.getSymbol(keycode, layer)

    @Slot(str, int, str)
    def setSymbol(self, keycode: str, layer: int, keysym: str):
        self._variant.setSymbol(keycode, layer, keysym)

    @Slot(str, int, result=str)
    def getSymbolOrFallback(self, keycode: str, layer: int, searchSelf: bool = False) -> str:
        return self._variant.getSymbolOrFallback(keycode, layer)

    @Slot(str, int, result=str)
    def getKeyChar(self, keycode: str, layer: int):
        return getchar(self.getSymbol(keycode, layer))

    @Slot(str, int, result=str)
    def getKeyCharFallback(self, keycode: str, layer: int):
        return getchar(self.getSymbolOrFallback(keycode, layer))

    @Slot()
    def reloadIncludes(self):
        self._variant.reloadIncludes()

    def setVariant(self, variant: xkb.Variant):
        self._variant = variant

    def toXkb(self) -> str:
        return self._variant.toXkb()

class SymbolsFile(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

        self._variantIndex: int = 0
        self._path: str = ""
        self._variants = VariantsList([], parent=self)

    variantChanged = Signal()
    error = Signal(str)

    pathChanged = Signal()
    @Property(str, notify=pathChanged)
    def path(self):
        return self._path

    @path.setter
    def path(self, str):
        self._path = urlparse(str).path
        self.pathChanged.emit()

    @Property(int, notify=variantChanged)
    def variantIndex(self):
        return self._variantIndex

    @variantIndex.setter
    def variantIndex(self, index: int):
        self._variantIndex = int(index)
        self.variantChanged.emit()

    @Property(QObject, notify=variantChanged)
    def variants(self):
        return self._variants

    @Property(Variant, notify=variantChanged)
    def variant(self) -> Variant | None:
        return self._variants.getRow(self._variantIndex)

    @Slot(str)
    def load(self, filePath: str):
        try:
            variants = xkb.getVariantsFromFile(urlparse(filePath).path)
            self._variants.setItems(variants)
            self._variantIndex = 0
            self.variantChanged.emit()
            self._path = urlparse(filePath).path
            self.pathChanged.emit()
        except UnicodeDecodeError:
            self.error.emit("Failed to open file. Not a text file.")

    @Slot(str, result=bool)
    def write(self, filePath: str) -> bool:
        try:
            with open(urlparse(filePath).path, 'w') as file:
                _ = file.write("\n\n".join([variant.toXkb() for variant in self._variants]))
            return True
        except Exception as err:
            self.error.emit(getattr(err, 'message', re.sub(pattern=r'\[Errno \d+\] ', repl='', string=str(err))))
        return False

    @Slot()
    def reset(self):
        self.variantIndex = 0 # pyright: ignore[reportAttributeAccessIssue]
        self.path = "" # pyright: ignore[reportAttributeAccessIssue]
        self._variants.reset()
        self.variantChanged.emit()
