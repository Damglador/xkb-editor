# pyright: reportOptionalMemberAccess=false

from pathlib import Path
import pytest

from xkbeditor import parser
from xkbeditor import layout
from textwrap import dedent

SAMPLES_DIR = Path(__file__).parent / "test-samples"

def testVariantFromFile():
    variant1 = parser.getVariantFromFile(SAMPLES_DIR / "my-layout", "custom")
    assert variant1 == parser.getVariantsFromFile(SAMPLES_DIR / "my-layout")[0]

def testVariants():
    variant1 = parser.getVariantFromFile(SAMPLES_DIR / "my-layout", "custom")
    variant2 = parser.fromString(variant1.toXkb())[0]
    assert variant1 == variant2, (
        f"Variants don't match!\nVariant1:\n{variant1}\nVariant2:\n{variant2}"
    )

def testXkb():
    variant1 = parser.getVariantFromFile(SAMPLES_DIR / "my-layout", "custom")
    xkb1 = variant1.toXkb()

    variant2 = parser.fromString(xkb1)[0]
    xkb2 = variant2.toXkb()
    assert xkb1 == xkb2

def testQuoteSymbols():
    with open(SAMPLES_DIR / "quotes", "r") as file:
        sourceXkb = file.read()
    variant = layout.Variant(
        id="quotes",
        keymap={
            "AB08": layout.KeyProps(symbols=["\"", "'", "“", "NoSymbol"])
        }
    )
    xkb = variant.toXkb()
    assert sourceXkb == xkb, dedent(f"""Generated XKB doesn't match with the test sample!
sample:
{sourceXkb}
generated:
{xkb}""")
