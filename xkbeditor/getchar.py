# xkbcommon doesn't type function
# pyright: reportUnknownVariableType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportMissingTypeStubs=false

from xkbcommon.xkb import keysym_from_name, keysym_to_string


def getchar(input: str) -> str:
    # Assume it's already a character
    if len(input) == 1:
        return input

    return keysym_to_string(keysym_from_name(input)) or ""

if __name__ == "__main__":
    import sys
    print(getchar(sys.argv[1]))
