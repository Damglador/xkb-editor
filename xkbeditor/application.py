#!/usr/bin/env python3

import os
import signal
import sys
from urllib.parse import urlparse

from PySide6.QtCore import QObject, QUrl, Signal, Slot
from PySide6.QtQml import QmlElement, QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from . import xkb
from .getchar import getchar

QML_IMPORT_NAME = "project"
QML_IMPORT_MAJOR_VERSION = 2


@QmlElement
class Bridge(QObject):
    variants: list[xkb.Variant] = []
    currentVariant: int = 0

    variantLoaded = Signal()
    failedOpen = Signal()
    failedSave = Signal()

    @property
    def variant(self):
        if 0 <= self.currentVariant < len(self.variants):
            return self.variants[self.currentVariant]
        else:
            return xkb.Variant()

    @Slot()
    def loadTestVariant(self):
        self.variants = xkb.getVariantsFromFile(os.path.expanduser("~/.config/xkb/symbols/us"))
        self.variantLoaded.emit()

    @Slot(str)
    def openFile(self, filePath: str):
        self.variants = xkb.getVariantsFromFile(urlparse(filePath).path)
        self.variantLoaded.emit()

    @Slot(str, int, result=str)
    def getKeyChar(self, keycode: str, layer: int):
        return getchar(self.variant.getSymbol(keycode, layer))

    @Slot(str, int, result=str)
    def getKeyCharFallback(self, keycode: str, layer: int):
        return getchar(self.variant.getSymbolOrFallback(keycode, layer, False))


def main():
    """Initializes and manages the application execution"""
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    app.setDesktopFileName("xkb-editor")

    """Needed to close the app with Ctrl+C"""
    _ = signal.signal(signal.SIGINT, signal.SIG_DFL)

    """Needed to get proper KDE style outside of Plasma"""
    if not os.environ.get("QT_QUICK_CONTROLS_STYLE"):
        os.environ["QT_QUICK_CONTROLS_STYLE"] = "org.kde.desktop"

    base_path = os.path.abspath(os.path.dirname(__file__))
    url = QUrl(f"file://{base_path}/qml/Main.qml")
    engine.load(url)

    if len(engine.rootObjects()) == 0:
        sys.exit()

    _ = app.exec()


if __name__ == "__main__":
    main()
