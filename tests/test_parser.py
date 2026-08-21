# pyright: reportOptionalMemberAccess=false

from pathlib import Path

from xkbeditor import xkb

SAMPLES_DIR = Path(__file__).parent / "symbols"

def test_getVariantFromFile():
    variant1 = xkb.getVariantFromFile(SAMPLES_DIR / "my-layout", "test")
    assert xkb.getVariantsFromFile(SAMPLES_DIR / "my-layout")[0] == variant1

def test_variant_from_generated_xkb():
    variant1 = xkb.getVariantFromFile(SAMPLES_DIR / "my-layout", "test")
    variant2 = xkb.fromString(variant1.toXkb())[0]
    assert variant2 == variant1, f"Variants don't match!\nVariant1:\n{variant1}\nVariant2:\n{variant2}"

def test_parse_generated_xkb():
    variant1 = xkb.getVariantFromFile(SAMPLES_DIR / "my-layout", "test")
    xkb1 = variant1.toXkb()

    variant2 = xkb.fromString(xkb1)[0]
    xkb2 = variant2.toXkb()
    assert xkb2 == xkb1

def test_quote_symbols():
    with open(SAMPLES_DIR / "quotes", "r") as file:
        sourceXkb = file.read()
    variant = xkb.Variant(
        id="test",
        keymap={
            "AB08": xkb.KeyProps(symbols=["\"", "'", "“", "NoSymbol"])
        }
    )
    xkbStr = variant.toXkb()
    assert xkbStr == sourceXkb, f"""Generated XKB doesn't match with the test sample!
sample:
{sourceXkb}
generated:
{xkb}"""

def test_toxkb():
    variant = xkb.getVariantFromFile(SAMPLES_DIR / "toxkb-reference", "test")
    xkbStr = variant.toXkb()

    with open(SAMPLES_DIR / "toxkb-reference", "r") as file:
        sourceXkb = file.read()
    assert xkbStr == sourceXkb

def test_upstream_us():
    variants = xkb.getVariantsFromFile("/usr/share/xkeyboard-config-2/symbols/us")
    assert variants != None
