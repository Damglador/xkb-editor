import re
from enum import Flag, StrEnum, auto
from typing import Any, override

from pydantic import BaseModel, ConfigDict


def isImplicit(symbol: Any | None) -> bool:
    match symbol:
        case "NoSymbol":
            return True
        case "":
            return True
        case None:
            return True
        case _:
            return False


# https://www.charvolant.org/doug/xkb/html/node5.html
class Flags(Flag):
    default = auto()
    partial = auto()
    hidden = auto()
    alphanumeric_keys = auto()
    modifier_keys = auto()
    keypad_keys = auto()
    function_keys = auto()
    alternate_group = auto()

# https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#merge-mode-def
class MergeMode(StrEnum):
    AUGMENT = "augment"
    OVERRIDE = "override"
    REPLACE = "replace"
    ALTERNATE = "alternate"


# https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#key-actions
class Action(BaseModel):
    name: str
    params: dict[str, str] = {}


# Max of 4 elements
Symbols = list[str]

Actions = list[Action]


class Include(BaseModel):
    path: str
    variant: str | None = None

    @override
    def __str__(self):
        if not self.variant:
            return f"{self.path}"
        else:
            return f"{self.path}({self.variant})"

    @staticmethod
    def fromString(string: str) -> Include:
        if string != "":
            match = re.match(r"(.*)\((.*)\)$", string)
            if match:
                return Include(path=match.group(1), variant=match.group(2))
            else:
                return Include(path=string)
        else:
            return Include(path="")


class KeyProps(BaseModel):
    def __init__(self, symbols: list[str] | None = None, **data):
        super().__init__(**data)
        if symbols is not None:
            self.symbols = symbols

    model_config = ConfigDict(arbitrary_types_allowed=True)

    _symbols: Symbols = ["NoSymbol", "NoSymbol", "NoSymbol", "NoSymbol"]
    actions: Actions | None = None
    virtmod: str | None = None
    repeat: bool | None = None
    type: str | None = None

    @property
    def symbols(self):
        return self._symbols

    @symbols.setter
    def symbols(self, syms: list[str] | None):
        if syms is None:
            return
        for i in range(min(len(syms), len(self._symbols))):
            if not isImplicit(syms[i]):
                self._symbols[i] = syms[i]

    # https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#merge-mode-def
    def merge(self, new: KeyProps, mode: MergeMode = MergeMode.OVERRIDE):
        match mode:
            # Override shall be first because it's the default
            # Alternate is ignored per the docs, so use the default, which is override
            case (
                MergeMode.OVERRIDE | MergeMode.ALTERNATE
            ):  # Write explicitly defined in NEW
                for i in range(len(new.symbols)):
                    if not isImplicit(new.symbols[i]):
                        self.symbols[i] = new.symbols[i]
                if not isImplicit(new.virtmod):
                    self.virtmod = new.virtmod
                if not isImplicit(new.repeat):
                    self.repeat = new.repeat
                if not isImplicit(new.type):
                    self.type = new.type
            case (
                MergeMode.AUGMENT
            ):  # Write explicitly defined in NEW for implicitly defined in OLD
                for i in range(len(new.symbols)):
                    if isImplicit(self.symbols[i]):
                        self.symbols[i] = new.symbols[i]
                if isImplicit(self.virtmod):
                    self.virtmod = new.virtmod
                if isImplicit(self.repeat):
                    self.repeat = new.repeat
                if isImplicit(self.type):
                    self.type = new.type
            case MergeMode.REPLACE:  # Overwrite all with NEW
                self.self = new
