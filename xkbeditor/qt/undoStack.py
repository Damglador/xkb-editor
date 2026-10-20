from PySide6.QtCore import QAbstractListModel, Slot
from PySide6.QtGui import QUndoStack
from PySide6.QtQml import QmlElement

from xkbeditor.qt.undo import *

QML_IMPORT_NAME = "xkbeditor"
QML_IMPORT_MAJOR_VERSION = 2


@QmlElement
class UndoStack(QUndoStack):
    @Slot(Variant, str, int, str)
    def setSymbol(self, variant: Variant, keycode: str, level: int, keysym: str):
        self.push(SetSymbol(variant, keycode, level, keysym))

    @Slot(QObject, str, str)
    def editText(self, target: QObject, property: str, text: str):
        self.push(EditText(target, property, text))

    @Slot(VariantsList, int)
    def removeVariant(self, variants: VariantsList, index: int):
        self.push(RemoveVariant(variants, index))

    @Slot(VariantsList, str)
    def addVariant(self, variants: VariantsList, id: str):
        self.push(AddVariant(variants, id))

    @Slot(Variant, str)
    def removeFlag(self, variant: Variant, flag: str):
        self.push(RemoveFlag(variant, flag))

    @Slot(Variant, str)
    def addFlag(self, variant: Variant, flag: str):
        self.push(AddFlag(variant, flag))

    @Slot(IncludesList, int)
    def removeInclude(self, includes: IncludesList, index: int):
        self.push(RemoveInclude(includes, index))

    @Slot(IncludesList, dict, result=bool)
    def addInclude(self, includes: IncludesList, vals: dict[str, str]):
        if not vals.get("path"):
            return False
        self.push(AddInclude(includes, vals))
        return True

    @Slot(QAbstractListModel, int, int)
    def moveElement(self, list: List, oldIndex: int, newIndex: int):
        self.push(MoveElement(list, oldIndex, newIndex))
