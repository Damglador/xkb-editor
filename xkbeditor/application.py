#!/usr/bin/env python3

import os
import signal
import sys

from PySide6.QtCore import Property, QObject, QUrl, Signal, Slot
from PySide6.QtQml import QmlElement, QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from .qttypes import SymbolsFile

QML_IMPORT_NAME = "xkbeditor"
QML_IMPORT_MAJOR_VERSION = 2


# pyright: reportUnannotatedClassAttribute=false
@QmlElement
class Bridge(QObject):
    fileChanged = Signal()
    error = Signal(str)

    def __init__(self):
        super().__init__()

        self._file = SymbolsFile(parent=self)

        _ = self.fileChanged.connect(self._file.variantChanged.emit)
        _ = self._file.error.connect(self.error.emit)
        _ = self.error.connect(self.print)

    @Property(SymbolsFile, notify=fileChanged)
    def file(self):
        return self._file

    @Slot()
    def loadTestVariant(self):
        self._file.load("/usr/share/xkeyboard-config-2/symbols/us")
        self._file.path = "/home/damglador/.config/xkb/symbols/test" # pyright: ignore[reportAttributeAccessIssue]

    @Slot()
    def newFile(self):
        self._file.reset()
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
    app.setApplicationName("Xkb Editor")
    app.setOrganizationName("damglador")

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
