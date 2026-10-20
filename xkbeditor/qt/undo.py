# pyright: reportUnknownParameterType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportMissingParameterType=false
# pyright: reportImplicitOverride=false
# pyright: reportUnannotatedClassAttribute=false
# pyright: reportUnknownMemberType=false

from PySide6.QtCore import QObject
from PySide6.QtGui import QUndoCommand

from xkbeditor.parser import xkb
from xkbeditor.qt.types import IncludesList, List, Variant, VariantsList


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

    def moveStr(self, str):
        return self.tr("Move «{}»").format(str)


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
            tr.removeStr(tr.includeStr(self.item.toString())),
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


class EditText(QUndoCommand):
    def __init__(self, target: QObject, property: str, text: str, parent=None):
        self.target = target
        self.property = property
        self.newText: str = text
        self.oldText: str = target.property(property)
        super().__init__(
            self.oldText + " → " + self.newText,
            parent=parent,
        )

    def id(self) -> int:
        return 1002

    def redo(self, /) -> None:
        self.target.setProperty(self.property, self.newText)

    def undo(self, /) -> None:
        self.target.setProperty(self.property, self.oldText)

    def mergeWith(self, other: EditText, /) -> bool:  # pyright: ignore[reportIncompatibleMethodOverride]
        if self.id() != other.id():
            return False

        if self.target != other.target:
            return False

        if self.property != other.property:
            return False

        self.newText = other.newText
        self.setText(self.oldText + " → " + self.newText)
        if (self.newText == self.oldText):
            self.setObsolete(True)

        return True


class SetSymbol(QUndoCommand):
    def __init__(
        self, variant: Variant, keycode: str, level: int, keysym: str, parent=None
    ):
        self.variant = variant
        self.keycode = keycode
        self.level = level
        self.newKeysym = keysym
        self.oldKeysym = variant.getSymbol(self.keycode, self.level)
        super().__init__(
            tr.setSymbolStr(
                self.keycode, str(self.variant.id), self.oldKeysym, self.newKeysym
            ),
            parent=parent,
        )

    def redo(self, /) -> None:
        self.variant.setSymbol(self.keycode, self.level, self.newKeysym)
        self.variant.symbolsChanged.emit()

    def undo(self, /) -> None:
        self.variant.setSymbol(self.keycode, self.level, self.oldKeysym)
        self.variant.symbolsChanged.emit()


class MoveElement(QUndoCommand):
    def __init__(self, list: List, oldIndex: int, newIndex: int, parent=None) -> None:
        self.list = list
        self.oldIndex = oldIndex
        self.newIndex = newIndex
        self.obj = self.list.get(oldIndex)
        itemName = self.list.data(self.list.index(oldIndex))
        super().__init__(tr.moveStr(itemName), parent=parent)

    def id(self) -> int:
        return 1001

    def redo(self, /) -> None:
        self.list.move(self.oldIndex, self.newIndex)

    def undo(self, /) -> None:
        self.list.move(self.newIndex, self.oldIndex)

    def mergeWith(self, other: MoveElement, /) -> bool:  # pyright: ignore[reportIncompatibleMethodOverride]
        if self.id() != other.id():
            return False

        if type(self.list) != type(other.list):
            return False

        if self.obj != other.obj:
            return False

        self.newIndex = other.newIndex
        if (self.newIndex == self.oldIndex):
            self.setObsolete(True)

        return True
