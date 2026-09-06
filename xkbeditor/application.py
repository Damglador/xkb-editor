#!/usr/bin/env python3

import os
import re
import signal
import sys
from urllib.parse import urlparse

from PySide6.QtCore import Property, QObject, QUrl, Signal, Slot
from PySide6.QtQml import QmlElement, QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from . import xkb, xkbtypes
from .getchar import getchar

QML_IMPORT_NAME = "project"
QML_IMPORT_MAJOR_VERSION = 2


# pyright: reportUnannotatedClassAttribute=false
@QmlElement
class Bridge(QObject):
    variants: list[xkb.Variant] = []
    _currentVariant: int = 0
    _openedFilePath: str = ""

    variantChanged = Signal()
    fileChanged = Signal()
    error = Signal(str)

    def __init__(self):
        super().__init__()
        _ = self.error.connect(self.print)

    @property
    def variant(self):
        if 0 <= self._currentVariant < len(self.variants):
            return self.variants[self._currentVariant]
        else:
            return xkb.Variant()

    @Property(str, notify=fileChanged)
    def openedFilePath(self) -> str:
        return self._openedFilePath

    @Property(str, notify=variantChanged)
    def variantName(self) -> str:
        return self.variant.id or ""

    @Property(list, notify=variantChanged)
    def includes(self) -> list[str]:
        return [str(include) or "" for include in self.variant.includes]

    @Property(list, notify=fileChanged)
    def variantsNames(self) -> list[str]:
        return [variant.id or "" for variant in self.variants]

    @Property(int, notify=variantChanged)
    def currentVariant(self) -> int:  # pyright: ignore[reportRedeclaration]
        return self._currentVariant

    @currentVariant.setter
    def currentVariant(self, value: int) -> None:
        self._currentVariant = value
        self.variantChanged.emit()

    @Property(int, notify=fileChanged)
    def variantsLength(self):
        return len(self.variants) - 1

    @Slot()
    def loadTestVariant(self):
        self.openFile("/usr/share/xkeyboard-config-2/symbols/us")

    @Slot(str)
    def openFile(self, filePath: str):
        try:
            self.variants = xkb.getVariantsFromFile(urlparse(filePath).path)
            self._openedFilePath = urlparse(filePath).path
            self.fileChanged.emit()
            self.variantChanged.emit()
        except UnicodeDecodeError:
            self.error.emit("Failed to open file. Not a text file.")


    @Slot(str)
    def saveFile(self, filePath: str):
        try:
            with open(urlparse(filePath).path, 'w') as file:
                _ = file.write("\n\n".join([variant.toXkb() for variant in self.variants]))
        except Exception as err:
            self.error.emit(getattr(err, 'message', re.sub(pattern=r'\[Errno \d+\] ', repl='', string=str(err))))


    @Slot(str)
    def print(self, message: str):
        print(message)

    @Slot(str, int, result=str)
    def getKeySym(self, keycode: str, layer: int):
        return self.variant.getSymbol(keycode, layer)

    @Slot(str, int, str)
    def setKeySym(self, keycode: str, layer: int, keysym: str):
        self.variant.setSymbol(keycode, layer, keysym)

    @Slot(str, int, result=str)
    def getKeyChar(self, keycode: str, layer: int):
        return getchar(self.variant.getSymbol(keycode, layer))

    @Slot(str, int, result=str)
    def getKeyCharFallback(self, keycode: str, layer: int):
        return getchar(self.variant.getSymbolOrFallback(keycode, layer, False))

    @Slot(int)
    def removeIncludeAt(self, index: int):
        print(f"Removing {index}")
        del self.variant.includes[index]
        self.variant.reloadIncludes()
        self.variantChanged.emit()

    @Slot(str)
    def addInclude(self, include: str):
        self.variant.includes.append(xkbtypes.Include.fromString(str(include)))
        self.variant.reloadIncludes()
        self.variantChanged.emit()

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
