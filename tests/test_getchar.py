from xkbeditor.getchar import getchar


def test_unicode():
    unicodes = [ "Cyrillic_en", "Cyrillic_JE", "kana_E", "comma", "topleftsummation", "notequal" ]
    sample   = [ "н", "Ј", "エ", ",", "", "≠" ]
    result   = []
    for item in unicodes:
        result.append(getchar(item))
    assert result == sample

def test_keysyms():
    keysyms = [ "U043d", "U0408", "U30a8", "U002c", "", "U2260" ]
    sample  = [ "н", "Ј", "エ", ",", "", "≠" ]
    result  = []
    for item in keysyms:
        result.append(getchar(item))
    assert result == sample

def test_hex():
    hexes  = [ "0x06ce", "0x06b8", "0x04b4", "0x002c", "0x08b1", "0x08bd" ]
    sample = [ "н", "Ј", "エ", ",", "", "≠" ]
    result = []
    for item in hexes:
        result.append(getchar(item))
    assert result == sample
