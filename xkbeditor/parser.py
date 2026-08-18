# pyright: reportUnknownParameterType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportUnknownMemberType=false
# pyright: reportUnknownVariableType=false
# pyright: reportMissingParameterType=false
# pyright: reportUnusedParameter=false

import os
import re
from pathlib import Path

from lark import Lark, Token, Transformer, Tree

from .globals import XKB_INCLUDE_PATHS
from .layout import Flags, Include, KeyProps, Variant

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
                        if variant.flags is None:
                            variant.flags = []
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
        match = re.match(r'(.*)\((.*)\)$', incl) # pyright: ignore[reportInvalidStringEscapeSequence]
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
                    keyprops.actions = None # TODO: Make this one work
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
            syms.append(str(item.value))
        return Token("SYMBOLS", syms)
    def key_acts(self, items):
        return Token("ACTIONS", "Bogus data")
    #     acts = []
    #     for item in items:
    #         acts.append(item.value)
    #     return Token("ACTIONS", acts)
    # def action(self, items):
    #     name, param, val = items

    def repeat(self, items):
        return Token("REPEAT", bool(items[0]))
    def key_type(self, items):
        return Token("TYPE", str(items[1]))
    def key_virtmod(self, items):
        return Token("VIRTMOD", str(items[0]))
