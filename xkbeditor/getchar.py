# xkbcommon doesn't type function
# pyright: reportUnknownVariableType=false
# pyright: reportUnknownArgumentType=false
# pyright: reportMissingTypeStubs=false

from xkbcommon.xkb import keysym_from_name, keysym_to_string


def getchar(input: str) -> str:
    # Assume it's already a character
    if len(input) == 1:
        return input
    match input:
        case "dead_tilde":
            return "˜"
        case "dead_diaeresis":
            return "¨"
        case "dead_circumflex":
            return "ˆ"
        case "dead_doubleacute":
            return "˝"
        case "dead_macron":
            return "ˉ"
        case "dead_horn":
            exit
        case "dead_ogonek":
            return "˛"
        case "dead_breve":
            return "˘"
        case "dead_belowdot":
            return " ̣̣̣̣"
        case "dead_hook":
            return " ̉"
        case "dead_abovering":
            return "˚"
        case "dead_caron":
            return "ˇ"
        case "dead_stroke":
            return "N/A"
        case "dead_grave":
            return "ˋ"
        case "dead_acute":
            return "ˊ"
        case "dead_iota":
            return "ᶥ"
        case _:
            pass
    return keysym_to_string(keysym_from_name(input)) or ""

if __name__ == "__main__":
    import sys
    print(getchar(sys.argv[1]))
