from PySide6.QtCore import QObject
from PySide6.QtGui import QUndoCommand

from xkbeditor.parser import xkb
from xkbeditor.qt.types import IncludesList, Variant, VariantsList


class UndoRedoActionText(QObject):
    def removeStr(self, str):
        return self.tr("Remove {}").format(str)

    def addStr(self, str):
        return self.tr("Add {}").format(str)

    def renameStr(self, str):
        return self.tr("Rename {}").format(str)

    def variantStr(self, str):
        return self.tr("variant «{}»").format(str)

    def includeStr(self, str):
        return self.tr("include «{}»").format(str)

    def flagStr(self, str):
        return self.tr("flag «{}»").format(str)

    def setSymbolStr(self, keycode: str, variant: str, oldKeysym: str, newKeysym: str):
        return self.tr(
            "Change symbol for {keycode} of {variant}: {oldKeysym} → {newKeysym}"
        ).format(
            keycode=keycode,
            variant=variant,
            oldKeysym=oldKeysym or "N/A",
            newKeysym=newKeysym or "N/A",
        )


tr = UndoRedoActionText()


class RemoveVariant(QUndoCommand):
    def __init__(self, variantList: VariantsList, index: int, parent=None):
        self.variantList = variantList
        self.index = index
        self.item: Variant = self.variantList.get(index)  # pyright: ignore[reportAttributeAccessIssue]
        super().__init__(
            tr.removeStr(tr.variantStr(self.item.id)),
            parent=parent,
        )

    def redo(self, /) -> None:
        self.variantList.remove(self.index)

    def undo(self, /) -> None:
        self.variantList.insert(self.index, self.item)


class AddVariant(QUndoCommand):
    def __init__(self, variantList: VariantsList, id: str, parent=None):
        self.variantList = variantList
        self.name = id
        self.index = variantList.rowCount()
        super().__init__(tr.addStr(tr.variantStr(self.name)), parent=parent)

    def redo(self, /) -> None:
        self.variantList.new(self.name)

    def undo(self, /) -> None:
        self.variantList.remove(self.index)


class RemoveFlag(QUndoCommand):
    def __init__(self, variant: Variant, flag: str, parent=None):
        self.variant = variant
        self.flag = xkb.Flags[flag]
        super().__init__(tr.removeStr(tr.flagStr(flag)), parent=parent)

    def redo(self, /) -> None:
        self.variant._variant.flags &= ~self.flag
        self.variant.flagsChanged.emit()

    def undo(self, /) -> None:
        self.variant._variant.flags |= self.flag
        self.variant.flagsChanged.emit()


class AddFlag(QUndoCommand):
    def __init__(self, variant: Variant, flag: str, parent=None):
        self.variant = variant
        self.flag = xkb.Flags[flag]
        super().__init__(tr.addStr(tr.flagStr(flag)), parent=parent)

    def redo(self, /) -> None:
        self.variant._variant.flags |= self.flag
        self.variant.flagsChanged.emit()

    def undo(self, /) -> None:
        self.variant._variant.flags &= ~self.flag
        self.variant.flagsChanged.emit()


class RemoveInclude(QUndoCommand):
    def __init__(self, includesList: IncludesList, index: int, parent=None):
        self.includesList = includesList
        self.index = index
        self.item = self.includesList._objs[index]
        super().__init__(
            tr.removeStr(tr.includeStr(self.item)),
            parent=parent,
        )

    def redo(self, /) -> None:
        self.includesList.remove(self.index)

    def undo(self, /) -> None:
        self.includesList.insert(self.index, self.item)


class AddInclude(QUndoCommand):
    def __init__(self, includesList: IncludesList, include: dict, parent=None):
        self.includesList = includesList
        self.include = include
        self.index = self.includesList.rowCount()
        super().__init__(
            tr.addStr(
                tr.includeStr(
                    include.get("path")
                    if not include.get("variant")
                    else f"{include.get('path')}({include.get('variant')})"
                )
            ),
            parent=parent,
        )

    def redo(self, /) -> None:
        self.includesList.append(self.include)

    def undo(self, /) -> None:
        self.includesList.remove(self.index)


class RenameVariant(QUndoCommand):
    def __init__(self, variant: Variant, newId: str, parent=None):
        self.variant = variant
        self.newId: str = newId
        self.oldId: str = self.variant.id  # pyright: ignore[reportAttributeAccessIssue]
        super().__init__(
            tr.renameStr(tr.variantStr(self.oldId + " → " + self.newId)),
            parent=parent,
        )

    def redo(self, /) -> None:
        self.variant.id = self.newId  # pyright: ignore[reportAttributeAccessIssue]

    def undo(self, /) -> None:
        self.variant.id = self.oldId  # pyright: ignore[reportAttributeAccessIssue]


class SetSymbol(QUndoCommand):
    def __init__(
        self, variant: Variant, keycode: str, layer: int, keysym: str, parent=None
    ):
        self.variant = variant
        self.keycode = keycode
        self.layer = layer
        self.newKeysym = keysym
        self.oldKeysym = variant.getSymbol(self.keycode, self.layer)
        super().__init__(
            tr.setSymbolStr(
                self.keycode, str(self.variant.id), self.oldKeysym, self.newKeysym
            ),
            parent=parent,
        )

    def redo(self, /) -> None:
        self.variant.setSymbol(self.keycode, self.layer, self.newKeysym)
        self.variant.symbolsChanged.emit()

    def undo(self, /) -> None:
        self.variant.setSymbol(self.keycode, self.layer, self.oldKeysym)
        self.variant.symbolsChanged.emit()
