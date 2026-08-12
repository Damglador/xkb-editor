from enum import StrEnum

from pydantic import BaseModel, ConfigDict

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


# https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#key-actions
ActionParam = str
Action = str

# Max of 4 elements
Symbols = list[str]

Actions = dict[Action, ActionParam]

class KeyProps(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)

    symbols: Symbols | None = None
    actions: Actions | None = None
    virtmod: str | None = None
    repeat: bool | None = None
    type: str | None = None

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
        indent: str = "   "
        lines: list[str] = []
        if self.flags is not None:
            lines.append(" ".join(self.flags))
        lines.append(f"xkb_symbols \"{self.id}\" {{")

        lines.append(indent + f"name[Group1] = \"{self.name}\"")
        lines.append("\n")
        if self.key_type is not None:
            lines.append(indent + f"key.type[Group1] = {self.key_type};")
        if self.includes is not None:
            for include in self.includes:
                lines.append(indent + f"include {include};")
        lines.append("\n")
        if self.keymap is not None:
            for keycode, keyprops in self.keymap.items():
                props: list[str] = []
                if keyprops.symbols is not None:
                    symbols: list[str] = []
                    for symbol in keyprops.symbols:
                        if len(symbol) == 1:
                            symbols.append(f"\"{symbol}\"")
                        else:
                            symbols.append(symbol)
                    symbolsStr = f"[ {",    ".join(symbols)} ]"
                    props.append(symbolsStr)
                if keyprops.actions is not None:
                    print("You didn't implement actions, bozo")
                if keyprops.type is not None:
                    props.append(f"type[Group1] = \"{keyprops.type}\"")

                propsStr = ", ".join(props)
                lines.append(indent + f"key <{keycode}> {{ {propsStr} }}")

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
    print(variant.toXkb())
    # print(Flags.ALPHANUMERIC_KEYS)
