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
        self.item: xkb.Variant = self.variantList._items[index]

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
