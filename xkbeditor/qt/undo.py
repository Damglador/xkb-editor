from PySide6.QtCore import QCoreApplication
from PySide6.QtGui import QUndoCommand

from xkbeditor import xkb
from xkbeditor.qt.types import IncludesList, Variant, VariantsList

removeStr = QCoreApplication.translate("Undo/Redo action", "Remove {}")
addStr = QCoreApplication.translate("Undo/Redo action", "Add {}")
variantStr = QCoreApplication.translate("Undo/Redo action", "variant «{}»")
includeStr = QCoreApplication.translate("Undo/Redo action", "include «{}»")
flagStr = QCoreApplication.translate("Undo/Redo action", "flag «{}»")


class RemoveVariant(QUndoCommand):
    def __init__(self, variantList: VariantsList, index: int, parent=None):
        super().__init__(removeStr.format(variantStr.format(variantList._items[index].id)), parent=parent)
        self.variantList = variantList
        self.index = index
        self.item: Variant = self.variantList.get(index) # pyright: ignore[reportAttributeAccessIssue]

    def redo(self, /) -> None:
        self.variantList.remove(self.index)

    def undo(self, /) -> None:
        self.variantList.insert(self.index, self.item)


class AddVariant(QUndoCommand):
    def __init__(self, variantList: VariantsList, id: str, parent=None):
        super().__init__(addStr.format(variantStr.format(id)), parent=parent)
        self.variantList = variantList
        self.name = id
        self.index = variantList.rowCount()

    def redo(self, /) -> None:
        self.variantList.new(self.name)

    def undo(self, /) -> None:
        self.variantList.remove(self.index)

class RemoveFlag(QUndoCommand):
    def __init__(self, variant: Variant, flag: str, parent=None):
        super().__init__(removeStr.format(flagStr.format(flag)), parent=parent)
        self.variant = variant
        self.flag = xkb.Flags[flag]

    def redo(self, /) -> None:
        self.variant._variant.flags &= ~self.flag
        self.variant.flagsChanged.emit()

    def undo(self, /) -> None:
        self.variant._variant.flags |= self.flag
        self.variant.flagsChanged.emit()


class AddFlag(QUndoCommand):
    def __init__(self, variant: Variant, flag: str, parent=None):
        super().__init__(addStr.format(flagStr.format(flag)), parent=parent)
        self.variant = variant
        self.flag = xkb.Flags[flag]

    def redo(self, /) -> None:
        self.variant._variant.flags |= self.flag
        self.variant.flagsChanged.emit()

    def undo(self, /) -> None:
        self.variant._variant.flags &= ~self.flag
        self.variant.flagsChanged.emit()


class RemoveInclude(QUndoCommand):
    def __init__(self, includesList: IncludesList, index: int, parent=None):
        super().__init__(removeStr.format(includeStr.format(includesList._items[index])), parent=parent)
        self.includesList = includesList
        self.index = index
        self.item = self.includesList._items[index]

    def redo(self, /) -> None:
        self.includesList.remove(self.index)

    def undo(self, /) -> None:
        self.includesList.insert(self.index, self.item)


class AddInclude(QUndoCommand):
    def __init__(self, includesList: IncludesList, include: dict[str, str], parent=None):
        super().__init__(
            addStr.format(includeStr.format(
                include.get("path")
                if not include.get("variant")
                else f"{include.get('path')}({include.get('variant')})"
            )),
            parent=parent)
        self.includesList = includesList
        self.include = include
        self.index = self.includesList.rowCount()

    def redo(self, /) -> None:
        self.includesList.append(self.include)

    def undo(self, /) -> None:
        self.includesList.remove(self.index)
