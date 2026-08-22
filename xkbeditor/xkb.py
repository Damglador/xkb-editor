# pyright: reportIgnoreCommentWithoutRule=false

import os
import re
from enum import StrEnum
from pathlib import Path
from types import NoneType
from typing import Any, override

from lark import Lark, Token, Transformer, Tree
from pydantic import BaseModel, ConfigDict

from .globals import XKB_INCLUDE_PATHS


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
class Action(BaseModel):
    name: str
    params: dict[str, str] = {}

# Max of 4 elements
Symbols = list[str]

Actions = list[Action]


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

    @override
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


class Variant(BaseModel):
    id: str | None = None  # xkb_symbols "<id>"
    # Human-readable name of the `variant`.
    # Defined as `name[Group1]="English (US, symbolic)";`
    name: str | None = None  # name[Group1] = "<name>"
    flags: list[Flags] = []
    keymap: dict[str, KeyProps] = {}
    includes: list[Include] = []
    key_type: str | None = None

    deps: list[Variant] | None = None

    def getSymbol(self, keycode: str, layer: int):
        sym = ""
        key = self.keymap.get(keycode)
        if key is not None:
            sym = key.symbols[layer - 1]
        if isImplicit(sym):
            sym = ""
        return sym

    def getSymbolOrFallback(self, keycode: str, layer: int, searchSelf: bool) -> str:
        if self.deps is None:
            self.loadIncludes()
        keysym: str = ""
        if searchSelf:
            keysym = self.getSymbol(keycode, layer)
            if not isImplicit(keysym):
                return keysym
        for dep in self.deps: # pyright: ignore self.deps shouldn't be None at this point
            result = dep.getSymbolOrFallback(keycode, layer, searchSelf=True)
            if not isImplicit(result):
                keysym = result
        return keysym

    def loadIncludes(self):
        if self.deps is None:
            self.deps = []
        for include in self.includes:
            variant = getVariant(include.path, include.variant)
            if variant is not None:
                self.deps.append(variant)

    def toXkb(self) -> str:
        indent: str = "    "
        lines: list[str] = []
        if self.flags != []:
            lines.append(" ".join(self.flags))
        lines.append(f'xkb_symbols "{self.id}" {{')

        if self.name is not None:
            lines.append(indent + f'name[Group1] = "{self.name}";')
            lines.append("")
        if self.key_type is not None:
            lines.append(indent + f"key.type[Group1] = {self.key_type};")
        if self.includes != []:
            for include in self.includes:
                lines.append(indent + f'include "{include}"')
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
                            symbols.append(f'"\\{symbol}"')
                        elif len(symbol) == 1 or symbol == r"\"":
                            symbols.append(f'"{symbol}"')
                        else:
                            symbols.append(symbol)
                    symbolsStr = f"[ {',    '.join(symbols)} ]"
                    props.append(symbolsStr)
                if keyprops.actions is not None:
                    actions: list[str] = []
                    for action in keyprops.actions:
                        params: list[str] = []
                        for param, val in action.params.items():
                            params.append(f'{param}={val}')
                        actions.append(f'{action.name}({",".join(params)})')
                    props.append(f'actions = [ {", ".join(actions)} ]')
                if keyprops.type is not None:
                    props.append(f'type = "{keyprops.type}"')
                if keyprops.repeat is not None:
                    props.append(f"repeat = {keyprops.repeat}")
                if keyprops.virtmod is not None:
                    props.append(f"virtualModifiers = {keyprops.virtmod}")

                propsStr = ",\n                   ".join(props)
                lines.append(indent + f"key <{keycode}> {{ {propsStr} }};")

        lines.append("};")
        return "\n".join(lines) + "\n"


lark: Lark = Lark.open("xkb.lark", rel_to=__file__, parser="lalr")

def getVariantsFromFile(filePath: Path | str) -> list[Variant]:
    variants: list[Variant] = []
    with open(filePath, "r") as file:
        variants = fromString(file.read())
    return variants

def getVariant(includePath: str, variantId: str | None = None) -> Variant | None:
    files: list[str] = []
    for includeDir in XKB_INCLUDE_PATHS:
        candidate = os.path.join(includeDir, "symbols", includePath)
        if os.path.isfile(candidate):
            files.append(candidate)
    result: Variant | None = None
    if variantId is not None:
        for file in files:
            variant = getVariantFromFile(file, variantId)
            if variant is not None:
                result = variant
    else:
        firstMatch: Variant | None = None
        for file in files:
            variants: list[Variant] = getVariantsFromFile(file)
            for variant in variants:
                if firstMatch is None:
                    firstMatch = variant
                if Flags.DEFAULT in variant.flags:
                    result = variant
        if result is None:
            result = firstMatch
    return result

def fromString(string: str) -> list[Variant]:
    return XkbTransformer().transform(lark.parse(string))

def getVariantFromFile(filePath: Path | str, variantId: str) -> Variant | None:
    variants = getVariantsFromFile(filePath)
    for variant in variants:
        if variant.id == variantId:
            return variant
    return None

# pyright: reportMissingParameterType=false, reportUnknownParameterType=false
# pyright: reportUnknownArgumentType=false,  reportUnknownMemberType=false
# pyright: reportUnknownVariableType=false,  reportAny=false
class XkbTransformer(Transformer[Token, list[Variant]]):
    def start(self, items) -> list[Variant]:
        variants = []
        for item in items:
            if type(item) is Tree:
                variants.append(VariantTransformer().transform(item))
        return variants

class VariantTransformer(Transformer[Token, Variant]):
    def variant(self, items) -> Variant:
        variant = Variant()
        for item in items:
            if type(item) is Token:
                match item.type:
                    case "FLAG":
                        variant.flags.append(Flags(item.value))
                    case "ID":
                        variant.id = str(item.value).strip('"')
                    case "NAME":
                        variant.name = str(item.value).strip('"')
                    case "INCLUDE":
                        variant.includes.append(item.value)

                    # TODO: Test those two
                    case "MODMAP":
                        pass
                    case "VIRTMODS":
                        pass
                    case "KEY":
                        variant.keymap.update(dict(item.value))
                    case _:
                        pass
        return variant

    def id(self, items):
        return Token("ID", str(items[0]))

    def name(self, items):
        for item in items:
            match item.type:
                case "GROUP":
                    pass
                case "STRING":
                    return Token("NAME", str(item.value))
                case _:
                    pass

    # https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#xkb-include
    def include(self, items):
        path, variant = [ "", None ]
        incl = str(items[0]).strip('"')
        match = re.match(r'(.*)\((.*)\)$', incl)
        if match:
            path = match.group(1)
            variant = match.group(2)
        else:
            path = incl
        return Token("INCLUDE", Include(path=path, variant=variant))

    def key(self, items):
        keycode = ""
        keyprops = KeyProps()
        for item in items:
            match item.type:
                case "KEYCODE":
                    keycode = str(item.value).strip("<>")
                case "KEYPROPS":
                    keyprops = item.value
                case _:
                    pass
        return Token("KEY", {keycode: keyprops})

    def key_props(self, items):
        keyprops = KeyProps()
        for item in items:
            match item.type:
                case "SYMBOLS":
                    keyprops.symbols = list(item.value)
                case "ACTIONS":
                    keyprops.actions = item.value # TODO: Make this one work
                case "REPEAT":
                    keyprops.repeat = item.value
                case "TYPE":
                    keyprops.type = str(item.value).strip('"')
                case "VIRTMOD":
                    keyprops.virtmod = item.value
                case _:
                    pass
        return Token("KEYPROPS", keyprops)

    def key_syms(self, items):
        syms = []
        for item in items:
            # Keep .value, it'll write tokens otherwise
            # DON'T strip('"'), because then it doesn't strip "\"" properly
            if str(item.value).startswith('"') and str(item.value).endswith('"'):
                item.value = item.value[1:-1]
            syms.append(str(item.value).replace(r'\"', '"'))
        return Token("SYMBOLS", syms)

    def key_acts(self, items):
        actions = Actions()
        for item in items:
            # If list is actions is empty, it is NoneType
            if type(item) is not NoneType:
                match item.type:
                    case "ACTION":
                        actions.append(item.value)
                    case _:
                        pass
            else:
                print(f"wtf is this?: {type(item)}")
        return Token("ACTIONS", actions)

    def action(self, items):
        name: str = ""
        params: dict[str, str] = {}
        for item in items:
            match item.type:
                case "ACTION":
                    name = item.value
                case "ACTION_PARAM":
                    params.update(dict(item.value))
                case _:
                    pass
        return Token("ACTION", Action(name=name, params=params))

    def action_param(self, items):
        return Token("ACTION_PARAM", {items[0].value: items[1].value})

    def repeat(self, items):
        return Token("REPEAT", bool(items[0]))

    def key_type(self, items):
        return Token("TYPE", str(items[1]))

    def key_virtmod(self, items):
        return Token("VIRTMOD", str(items[0]))
