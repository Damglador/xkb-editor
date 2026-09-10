#!/usr/bin/env python3

import os
import re
import signal
import sys
from urllib.parse import urlparse

from PySide6.QtCore import Property, QObject, QUrl, Signal, Slot
from PySide6.QtQml import QmlElement, QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from . import qttypes, xkbtypes
from .qttypes import SymbolsFile
from .getchar import getchar

QML_IMPORT_NAME = "project"
QML_IMPORT_MAJOR_VERSION = 2


# pyright: reportUnannotatedClassAttribute=false
@QmlElement
class Bridge(QObject):
    variantChanged = Signal()
    fileChanged = Signal()
    error = Signal(str)

    def __init__(self):
        super().__init__()

        self._file = SymbolsFile(parent=self)

        _ = self.fileChanged.connect(self.variantChanged.emit)
        _ = self.error.connect(self.print)

    @Property(SymbolsFile, notify=fileChanged)
    def file(self): return self._file

    @Property(list, notify=fileChanged)
    def variantsNames(self) -> list[str]:
        return [variant.id or "" for variant in self._file._variants]

    @Slot()
    def loadTestVariant(self):
        self._file.load("/usr/share/xkeyboard-config-2/symbols/us")

    @Slot()
    def newFile(self):
        self._file = SymbolsFile()
        self.fileChanged.emit()

    @Slot(str)
    def print(self, message: str):
        print(message)

    @Slot(result=str)
    def getLicense(self) -> str:
        with open("LICENSE", "r") as file:
            return str(file.read())


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
