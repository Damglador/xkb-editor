from xkbeditor.getchar import getchar

sample = ["н", "Ј", "エ", ",", "", "≠", "Ư", "ư", "Ủ", "ủ"]


def test_unicode():
    unicodes = [
        "Cyrillic_en",
        "Cyrillic_JE",
        "kana_E",
        "comma",
        "topleftsummation",
        "notequal",
        "Uhorn",
        "uhorn",
        "Uhook",
        "uhook"
    ]
    result = []
    for item in unicodes:
        result.append(getchar(item))
    assert result == sample


def test_keysyms():
    keysyms = ["U043d", "U0408", "U30a8", "U002c", "", "U2260", "U01AF", "U01B0", "U1EE6", "U1EE7"]
    result = []
    for item in keysyms:
        result.append(getchar(item))
    assert result == sample


def test_hex():
    hexes = [
        "0x06ce",
        "0x06b8",
        "0x04b4",
        "0x002c",
        "0x08b1",
        "0x08bd",
        "0x10001af",
        "0x10001b0",
        "0x1001ee6",
        "0x1001ee7"
    ]
    result = []
    for item in hexes:
        result.append(getchar(item))
    assert result == sample
