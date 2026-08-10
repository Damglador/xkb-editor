from pathlib import Path
from lark import Lark, Token, Transformer, v_args
from layout import Variant


def getVariant(layoutName: str, variant: str):
    return None


def getVariantFromFile(filePath: Path, variant: str):
    return None


def test():
    parser: Lark = Lark.open("xkb.lark", rel_to=__file__, parser="lalr")
    with open("test-sample", "r") as file:
        tree = parser.parse(file.read())
        print(tree.pretty())


test()
