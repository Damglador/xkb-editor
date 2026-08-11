from pathlib import Path
from lark import Lark, Token, Transformer, v_args, Tree
from layout import Symbols, Variant, KeyProps
import layout


def getVariant(layoutName: str, variant: str):
    return None


def getVariantFromFile(filePath: Path, variant: str):
    return None

class XkbTransformer(Transformer):
    def __init__(self):
        super().__init__()
        self.variantList: list[Variant] = []

    def key(self, items):
        data = {}
        keycode = ""
        keyprops = KeyProps()
        for item in items:
            if item.type == "KEYCODE":
                keycode = item
            if type(item) is KeyProps:
                data[keycode] = item
        return data

    def key_props(self, items):
        key = KeyProps()
        for item in items:
            print(type(item))
            if item.type == "key_syms":
                print("the above one is Symbols")
                key.symbols = item
            if item.type == "key_type":
                key.type = item.children[1]
        return key

    # def key_syms(self, items):
    #     return
    # def key_type(self, items):
    #     return str(items[1])

def test():
    parser: Lark = Lark.open("xkb.lark", rel_to=__file__, parser="lalr")
    with open("test-sample", "r") as file:
        tree = parser.parse(file.read())
        # print(tree.pretty())
        print(XkbTransformer().transform(tree))


test()
