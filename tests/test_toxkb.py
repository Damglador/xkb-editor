# pyright: reportOptionalMemberAccess=false

from pathlib import Path

from xkbeditor.parser import xkb

SAMPLES_DIR = Path(__file__).parent / "symbols"

def test_toxkb():
    variant = xkb.getVariantFromFile(SAMPLES_DIR / "toxkb-reference", "test")
    xkbStr = variant.toXkb()

    with open(SAMPLES_DIR / "toxkb-reference", "r") as file:
        sourceXkb = file.read()
    assert sourceXkb == xkbStr


def test_alignment():
    variant = xkb.getVariantFromFile(SAMPLES_DIR / "alignment", "test")
    xkbStr = variant.toXkb()

    with open(SAMPLES_DIR / "alignment", "r") as file:
        sourceXkb = file.read()
    assert sourceXkb == xkbStr
