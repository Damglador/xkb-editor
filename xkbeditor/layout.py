from enum import Enum, StrEnum, auto
from typing import Any

from pydantic import BaseModel, ConfigDict, SerializationInfo

from collections import UserList

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

class KeyProps(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)

    symbols: Symbols | None = None
    actions: Actions | None = None
    virtmod: str | None = None
    repeat: bool | None = None
    type: str | None = None

    # https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#merge-mode-def
    def merge(self, new: KeyProps, mode: MergeMode = MergeMode.OVERRIDE):
        match mode:
            # Override shall be first because it's the default
            # Alternate is ignored per the docs, so use the default, which is override
            case MergeMode.OVERRIDE | MergeMode.ALTERNATE: # Write explicitly defined in NEW
                if new.symbols is not None and self.symbols is not None:
                    for i in range(0, len(new.symbols)):
                        if not isImplicit(new.symbols[i]):
                            self.symbols[i] = new.symbols[i]
                if not isImplicit(new.virtmod):
                    self.virtmod = new.virtmod
                if not isImplicit(new.repeat):
                    self.repeat = new.repeat
                if not isImplicit(new.type):
                    self.type = new.type
                pass
            case MergeMode.AUGMENT: # Write explicitly defined in NEW for implicitly defined in OLD
                if new.symbols is not None and self.symbols is not None:
                    for i in range(0, len(new.symbols)):
                        if isImplicit(self.symbols[i]):
                            self.symbols[i] = new.symbols[i]
                if isImplicit(self.virtmod):
                    self.virtmod = new.virtmod
                if isImplicit(self.repeat):
                    self.repeat = new.repeat
                if isImplicit(self.type):
                    self.type = new.type
                pass
            case MergeMode.REPLACE: # Overwrite all with NEW
                self = new
                pass


class Variant(BaseModel):
    id: str | None = None # xkb_symbols "<id>"
    # Human-readable name of the `variant`.
    # Defined as `name[Group1]="English (US, symbolic)";`
    name: str | None = None # name[Group1] = "<name>"
    flags: list[Flags] | None = None
    keymap: dict[str, KeyProps] | None = None
    includes: list[str] | None = None
    key_type: str | None = None

    def toXkb(self) -> str:
        indent: str = "    "
        lines: list[str] = []
        if self.flags is not None:
            lines.append(" ".join(self.flags))
        lines.append(f"xkb_symbols \"{self.id}\" {{")

        if self.name is not None:
            lines.append(indent + f"name[Group1] = \"{self.name}\"")
            lines.append("")
        if self.key_type is not None:
            lines.append(indent + f"key.type[Group1] = {self.key_type};")
        if self.includes is not None:
            for include in self.includes:
                lines.append(indent + f"include \"{include}\"")
            lines.append("")
        if self.keymap is not None:
            for keycode, keyprops in self.keymap.items():
                props: list[str] = []
                if keyprops.symbols is not None:
                    symbols: list[str] = []
                    for symbol in keyprops.symbols:
                        if symbol == '"':
                            symbols.append(f"\"\\{symbol}\"")
                        elif len(symbol) == 1:
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

                propsStr = ", ".join(props)
                lines.append(indent + f"key <{keycode}> {{ {propsStr} }};")

        lines.append("};")
        return "\n".join(lines) + "\n"

if __name__ == "__main__":

    variant = Variant(id="custom",
            name="Test Layout",
            flags=[Flags.DEFAULT, Flags.ALPHANUMERIC_KEYS],
            keymap={
                "AE29": KeyProps(symbols=["a", "A", "b", "B"], type="TWO_LAYER")
                },
            )
