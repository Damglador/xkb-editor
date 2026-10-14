# pyright: reportRedeclaration=false

from enum import Enum, auto

from PySide6.QtCore import (
    Property,
    QEnum,
    QObject,
    Signal,
    Slot,
)

from xkbeditor.parser import xkb


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


class Include(QObject):
    def __init__(self, include: xkb.Include, parent=None):
        super().__init__(parent)
        self._include = include
        self.pathChanged.connect(self.availableChanged.emit)
        self.variantChanged.connect(self.availableChanged.emit)

    pathChanged = Signal()

    @Property(str, notify=pathChanged)
    def path(self):
        return self._include.path

    @path.setter
    def path(self, str):
        self._include.path = str
        self.pathChanged.emit()

    variantChanged = Signal()

    @Property(str, notify=variantChanged)
    def variant(self):
        return self._include.variant

    @variant.setter
    def variant(self, str):
        self._include.variant = str
        self.variantChanged.emit()

    availableChanged = Signal()

    @Property(bool, notify=availableChanged)
    def available(self):
        xkb.ensure(self._include)
        return xkb.includesDB.get(str(self._include)) != None

    @Property(str, notify=availableChanged)
    def file(self):
        xkb.ensure(self._include)
        variant = xkb.includesDB.get(str(self._include))
        if variant:
            return variant._source

    @Slot(result=str)
    def toString(self) -> str:
        return str(self._include)


class Modifier(QObject):
    def __init__(self, id: str, text: str, isGlobal: bool):
        super().__init__(None)
        self._id = id
        self._text = text
        self._isGlobal = isGlobal

    @Property(str, constant=True)
    def id(self):
        return self._id

    @Property(str, constant=True)
    def text(self):
        return self._text

    @Property(bool, constant=True)
    def isGlobal(self):
        return self._isGlobal
