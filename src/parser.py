# pyright: reportUnknownParameterType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportUnknownMemberType=false
# pyright: reportUnknownVariableType=false
# pyright: reportMissingParameterType=false
# pyright: reportUnusedParameter=false

from pathlib import Path
from lark import Lark, Token, Transformer, v_args, Tree
from layout import Variant, KeyProps, Flags
import layout

from dataclasses import dataclass


def getVariant(layoutName: str, variant: str):
    return None


def getVariantFromFile(filePath: Path, variant: str):
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
                        variant.flags.append(Flags(item))
                    case "NAME":
                        variant.name = item
                    case "include":
                        if variant.includes is None:
                            variant.includes = []
                        variant.includes.append(item)

                    # TODO: Test those two
                    case "MODMAP":
                        pass
                    case "VIRTMODS":
                        pass
                    case "KEY":
                        if variant.keymap is None:
                            variant.keymap = {}
                        variant.keymap.update(dict(item.value))
                    case _:
                        pass
        return variant

    def name(self, items):
        for item in items:
            match item.type:
                case "GROUP":
                    pass
                case "STRING":
                    return Token("NAME", item)

    def key(self, items):
        keycode = ""
        keyprops = KeyProps()
        for item in items:
            match item.type:
                case "KEYCODE":
                    keycode = str(item.value).strip("<>")
                case "KEYPROPS":
                    keyprops = item.value
        return Token("KEY", dict({keycode: keyprops}))

    def key_props(self, items):
        keyprops = KeyProps()
        for item in items:
            print(item)
            match item.type:
                case "SYMBOLS":
                    keyprops.symbols = list(item.value)
                case "ACTIONS":
                    keyprops.actions = None # TODO: Make this one work
                case "REPEAT":
                    keyprops.repeat = item.value
                case "TYPE":
                    keyprops.type = item.value
                case _:
                    pass
        return Token("KEYPROPS", keyprops)

    def key_syms(self, items):
        syms = []
        for item in items:
            # Keep .value, it'll write tokens otherwise
            syms.append(item.value)
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

def test():
    parser: Lark = Lark.open("xkb.lark", rel_to=__file__, parser="lalr")
    with open("test-sample", "r") as file:
        tree = parser.parse(file.read())
        print(tree.pretty())
        trans = XkbTransformer().transform(tree)
        for tran in trans:
            print(tran.toXkb())


test()
