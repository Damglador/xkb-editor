from PySide6.QtGui import QUndoCommand

from xkbeditor import xkb
from xkbeditor.qt.types import VariantsList


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
