from PySide6.QtGui import QUndoCommand

from xkbeditor import xkb
from xkbeditor.qt.types import Variant, VariantsList


class RemoveVariant(QUndoCommand):
    def __init__(self, variantList: VariantsList, index: int, parent=None):
        super().__init__(parent=parent)
        self.variantList = variantList
        self.index = index
        self.item: xkb.Variant = self.variantList.get(self.index)._variant # pyright: ignore

    def redo(self, /) -> None:
        self.variantList.remove(self.index)

    def undo(self, /) -> None:
        self.variantList.insert(self.index, self.item)

class AddVariant(QUndoCommand):
    def __init__(self, variantList: VariantsList, id: str, parent=None):
        super().__init__(parent=parent)
        self.variantList = variantList
        self.name = id
        self.index = variantList.rowCount()

    def redo(self, /) -> None:
        self.variantList.new(self.name)

    def undo(self, /) -> None:
        self.variantList.remove(self.index)

class RemoveFlag(QUndoCommand):
    def __init__(self, variant: Variant, flag: str, parent=None):
        super().__init__(parent=parent)
        self.variant = variant
        self.flag = xkb.Flags[flag]

    def redo(self, /) -> None:
        self.variant._variant.flags &= ~self.flag
        self.variant.flagsChanged.emit()

    def undo(self, /) -> None:
        self.variant._variant.flags  |= self.flag
        self.variant.flagsChanged.emit()

class AddFlag(QUndoCommand):
    def __init__(self, variant: Variant, flag: str, parent=None):
        super().__init__(parent=parent)
        self.variant = variant
        self.flag = xkb.Flags[flag]

    def redo(self, /) -> None:
        self.variant._variant.flags |= self.flag
        self.variant.flagsChanged.emit()

    def undo(self, /) -> None:
        self.variant._variant.flags &= ~self.flag
        self.variant.flagsChanged.emit()
