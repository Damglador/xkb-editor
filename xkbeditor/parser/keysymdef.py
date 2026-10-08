# pyright: reportMissingTypeArgument=false
# pyright: reportUnknownParameterType=false
# pyright: reportMissingParameterType=false
# pyright: reportUnknownVariableType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportUnknownMemberType=false
# pyright: reportAny=false


from lark import Lark, Token, Transformer

from xkbeditor.getchar import keysym_to_string

parser: Lark = Lark.open("keysymdef.lark", rel_to=__file__, parser="lalr")

class Keysym:
    name: str = ""
    hex: str = ""
    char: str = ""
    desc: str = ""

class KeysymdefTransformer(Transformer[Token, list]):
    def start(self, items):
        result: list[dict[str, str]] = []
        for item in items:
            if type(item) == Keysym:
                result.append(item.__dict__)
            if type(item) == Token:
                match item.type:
                    case "COPYRIGHT":
                        result.insert(0, {"desc": str(item.value).strip("/* \n")})
                    case "DOC":
                        result.insert(1, {"desc": str(item.value).strip("/* \n")})

        return result

    def keysym(self, items):
        keysym = Keysym()
        for item in items:
            if type(item) == Token:
                match item.type:
                    case "KEYSYMNAME":
                        keysym.name = str(item.value).removeprefix("XK_")
                    case "HEX":
                        keysym.hex = str(item.value)
                        keysym.char = keysym_to_string(int(item.value, 16))
                    case "DESC":
                        keysym.desc = str(item.value).removeprefix("/*").removesuffix("*/").strip()
                    case _:
                        pass
        return keysym

def getTableFromFile(path: str):
    with open(path, 'r') as file:
        return KeysymdefTransformer().transform(parser.parse(file.read()))

if __name__ == "__main__":
    print(getTableFromFile("/usr/include/X11/keysymdef.h"))
