from ctypes import c_uint32, cdll
from ctypes.util import find_library

xkbcommon_path = find_library("xkbcommon")
if xkbcommon_path:
    xkbcommon = cdll.LoadLibrary(xkbcommon_path)
else:
    raise OSError("Could not find libxkbcommon")

def keysym_from_name(name: str) -> int:
    return xkbcommon.xkb_keysym_from_name(name.encode("utf-8"), 0)

def keysym_to_string(keysym: int) -> str:
    return chr(xkbcommon.xkb_keysym_to_utf32(c_uint32(keysym))).strip('\x00')

# xkb_keysym_from_name will return 0 on NoSymbol or when there's invalid name
# by that it's possible to determine if a keysym is valid or not
# and then if it has a displayable character
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
            return " ̛"
        case "dead_ogonek":
            return "˛"
        case "dead_breve":
            return "˘"
        case "dead_abovedot":
            return " ̇"
        case "dead_belowdot":
            return " ̣"
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
        case "dead_cedilla":
            return "¸"
        case _:
            pass
    return keysym_to_string(keysym_from_name(input)) or ""

if __name__ == "__main__":
    import sys
    print(getchar(sys.argv[1]))
