from xkbcommon.xkb import keysym_from_name, keysym_to_string


def getchar(input: str) -> str:
    # Assume it's already a character
    if len(input) == 1:
        return input
    if input.startswith("0x"):
        return keysym_to_string(int(input, 16)) or ""
    if len(input) == 5 and input.startswith("U"):
        try:
            return getCharFromUnicode(input)
        except ValueError:
            print("Not a unicode codepoint: " + input)

    return keysym_to_string(keysym_from_name(input)) or ""

def getCharFromUnicode(unicode: str):
    char = chr(int(unicode[1:5], base=16))
    # print(f"Unicode: {unicode} → Char: {char}")
    return char if char != "\x00" else ""
