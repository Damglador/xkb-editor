from enum import StrEnum
from typing import Any

from pydantic import BaseModel, ConfigDict


# https://www.charvolant.org/doug/xkb/html/node5.html
class Flags(StrEnum):
    DEFAULT = "default"
    PARTIAL = "partial"
    HIDDEN = "hidden"
    ALPHANUMERIC_KEYS = "alphanumeric_keys"
    MODIFIER_KEYS = "modifier_keys"
    KEYPAD_KEYS = "keypad_keys"
    FUNCTION_KEYS = "function_keys"
    ALTERNATE_GROUP = "alternate_group"

# https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#merge-mode-def
class MergeMode(StrEnum):
    AUGMENT = "augment"
    OVERRIDE = "override"
    REPLACE = "replace"
    ALTERNATE = "alternate"


# https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#key-actions
ActionParam = str
Action = str

# Max of 4 elements
Symbols = list[str]

Actions = dict[Action, ActionParam]

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

class Include(BaseModel):
    path: str
    variant: str | None

    def __str__(self):
        if self.variant is None:
            return f"{self.path}"
        else:
            return f"{self.path}({self.variant})"

class KeyProps(BaseModel):
    def __init__(self, symbols: list[str] | None = None, **data):
        super().__init__(**data)
        if symbols is not None:
            self.symbols = symbols

    model_config = ConfigDict(arbitrary_types_allowed=True)

    _symbols: Symbols = [ "NoSymbol", "NoSymbol", "NoSymbol", "NoSymbol" ]
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
            case MergeMode.OVERRIDE | MergeMode.ALTERNATE: # Write explicitly defined in NEW
                if new.symbols is not None and self.symbols is not None:
                    for i in range(len(new.symbols)):
                        if not isImplicit(new.symbols[i]):
                            self.symbols[i] = new.symbols[i]
                if not isImplicit(new.virtmod):
                    self.virtmod = new.virtmod
                if not isImplicit(new.repeat):
                    self.repeat = new.repeat
                if not isImplicit(new.type):
                    self.type = new.type
            case MergeMode.AUGMENT: # Write explicitly defined in NEW for implicitly defined in OLD
                if new.symbols is not None and self.symbols is not None:
                    for i in range(len(new.symbols)):
                        if isImplicit(self.symbols[i]):
                            self.symbols[i] = new.symbols[i]
                if isImplicit(self.virtmod):
                    self.virtmod = new.virtmod
                if isImplicit(self.repeat):
                    self.repeat = new.repeat
                if isImplicit(self.type):
                    self.type = new.type
            case MergeMode.REPLACE: # Overwrite all with NEW
                self.self = new


class Variant(BaseModel):
    id: str | None = None # xkb_symbols "<id>"
    # Human-readable name of the `variant`.
    # Defined as `name[Group1]="English (US, symbolic)";`
    name: str | None = None # name[Group1] = "<name>"
    flags: list[Flags] = []
    keymap: dict[str, KeyProps] = {}
    includes: list[Include] = []
    key_type: str | None = None

    deps: list[Variant] = []

    def getSymbol(self, keycode: str, layer: int):
        sym = ""
        key = self.keymap.get(keycode)
        if key is not None:
            sym = key.symbols[layer - 1]
        if isImplicit(sym):
            sym = ""
        return sym

    def getSymbolOrFallback(self, keycode: str, layer: int, searchSelf: bool) -> str:
        keysym: str = ""
        if searchSelf:
            keysym = self.getSymbol(keycode, layer)
            if not isImplicit(keysym):
                return keysym
        for dep in self.deps:
            result = dep.getSymbolOrFallback(keycode, layer, searchSelf=True)
            if not isImplicit(result):
                keysym = result
        return keysym

    def toXkb(self) -> str:
        indent: str = "    "
        lines: list[str] = []
        if self.flags != []:
            lines.append(" ".join(self.flags))
        lines.append(f"xkb_symbols \"{self.id}\" {{")

        if self.name is not None:
            lines.append(indent + f"name[Group1] = \"{self.name}\";")
            lines.append("")
        if self.key_type is not None:
            lines.append(indent + f"key.type[Group1] = {self.key_type};")
        if self.includes != []:
            for include in self.includes:
                lines.append(indent + f"include \"{include}\"")
            lines.append("")
        if self.keymap != {}:
            for keycode, keyprops in self.keymap.items():
                props: list[str] = []
                if keyprops.symbols != []:
                    symbols: list[str] = []
                    # Count the last explicit symbol in the list to avoid adding trailing NoSymbol to keysyms list
                    explicitSymbols: int = 0
                    for i in range(len(keyprops.symbols)):
                        if not isImplicit(keyprops.symbols[i]):
                            explicitSymbols = i + 1
                    for i in range(explicitSymbols):
                        symbol = keyprops.symbols[i]
                        if symbol == '"':
                            symbols.append(f"\"\\{symbol}\"")
                        elif len(symbol) == 1 or symbol == r'\"':
                            symbols.append(f"\"{symbol}\"")
                        else:
                            symbols.append(symbol)
                    symbolsStr = f"[ {",    ".join(symbols)} ]"
                    props.append(symbolsStr)
                if keyprops.actions is not None:
                    print("You didn't implement actions, bozo")
                if keyprops.type is not None:
                    props.append(f"type[Group1] = \"{keyprops.type}\"")
                if keyprops.repeat is not None:
                    props.append(f"repeat = {keyprops.repeat}")
                if keyprops.virtmod is not None:
                    props.append(f"virtualModifiers = {keyprops.virtmod}")

                propsStr = ",\n                   ".join(props)
                lines.append(indent + f"key <{keycode}> {{ {propsStr} }};")

        lines.append("};")
        return "\n".join(lines) + "\n"
