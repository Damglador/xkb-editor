# pyright: reportOptionalMemberAccess=false

from pathlib import Path
import pytest

from xkbeditor import parser
from xkbeditor import layout

SAMPLES_DIR = Path(__file__).parent / "symbols"

def testVariantFromFile():
    variant1 = parser.getVariantFromFile(SAMPLES_DIR / "my-layout", "test")
    assert variant1 == parser.getVariantsFromFile(SAMPLES_DIR / "my-layout")[0]

def testVariants():
    variant1 = parser.getVariantFromFile(SAMPLES_DIR / "my-layout", "test")
    variant2 = parser.fromString(variant1.toXkb())[0]
    assert variant1 == variant2, f"Variants don't match!\nVariant1:\n{variant1}\nVariant2:\n{variant2}"

def test_parse_generated_xkb():
    variant1 = parser.getVariantFromFile(SAMPLES_DIR / "my-layout", "test")
    xkb1 = variant1.toXkb()

    variant2 = parser.fromString(xkb1)[0]
    xkb2 = variant2.toXkb()
    assert xkb1 == xkb2

def testQuoteSymbols():
    with open(SAMPLES_DIR / "quotes", "r") as file:
        sourceXkb = file.read()
    variant = layout.Variant(
        id="test",
        keymap={
            "AB08": layout.KeyProps(symbols=["\"", "'", "“", "NoSymbol"])
        }
    )
    xkb = variant.toXkb()
    assert xkb == sourceXkb, f"""Generated XKB doesn't match with the test sample!
sample:
{sourceXkb}
generated:
{xkb}"""

def test_toxkb():
    variant = parser.getVariantFromFile(SAMPLES_DIR / "toxkb-reference", "test")
    xkb = variant.toXkb()

    with open(SAMPLES_DIR / "toxkb-reference", "r") as file:
        sourceXkb = file.read()
    assert xkb == sourceXkb
