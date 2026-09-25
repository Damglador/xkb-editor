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

# When the currentIndex is on 0, the VariantList creates an object of Variant for bridge.file,
# the reference to which is saved here and used in UI. But when current index changes,
# the UI receives a new instance object of Variant, which is linked to the same data,
# but since the object of Variant here is different, the UI doesn't receive the update
# signals from here, which causes the data to update, while UI remains unchanged.
# Getting from index of VariantList won't work either as it creates a new object
# of Variant each time. Getting from SymbolsFile each call also doesn't work
# as it will give variant at current index instead of one that action was performed on.
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
