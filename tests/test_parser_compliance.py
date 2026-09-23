import os

from xkbeditor import xkb

# def test_loadIncludes_on_us():
#     variants = xkb.getVariantsFromFile("/usr/share/xkeyboard-config-2/symbols/us")
#     for index in range(len(variants)):
#         variants[index].loadIncludes()

    # assert [variant.getSymbolOrFallback("AD02", 1) for variant in variants if variant.id == "sun_type6"] == "w"
    #
def test_parsing_all_symbols_files():
    variants: list[list[xkb.Variant]] = []
    for e in os.scandir("/usr/share/xkeyboard-config-2/symbols/"):
        if e.is_file():
            load = xkb.getVariantsFromFile(e.path)
            variants.append(load)
