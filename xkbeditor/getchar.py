import csv

with open("./xkbeditor/keysyms.csv", 'r') as file:
    # keysymTable = csv.DictReader(file, delimiter="	")
    table = csv.reader(file, delimiter="\t")
    next(table) # Skip header
    keysymTable: dict[str, str] = {}
    hexTable: dict[str, str] = {}
    for row in table:
        # codename, unicode, hex, comment = row
        keysymTable.update({row[0]: row[1]})
        hexTable.update({row[2]: row[1]})

def getchar(input: str) -> str:
    # Assume it's already a character
    if len(input) == 1:
        return input
    if input in keysymTable:
        return getCharFromUnicode(keysymTable[input])
    if len(input) == 5 and input.startswith("U"):
        return getCharFromUnicode(input)
    if input in hexTable:
        return getCharFromUnicode(hexTable[input])
    # if len(input) == 6 and input.startswith("0x"):
    #     return getCharFromHex(input)

    return ""

def getCharFromUnicode(unicode: str):
    char = chr(int(unicode[1:5], base=16))
    # print(f"Unicode: {unicode} → Char: {char}")
    return char if char != "\x00" else ""
