#!/usr/bin/env python3
# pyright: reportPrivateUsage=false

import os
import signal
import sys

from PySide6.QtCore import (
    Property,
    QCoreApplication,
    QLocale,
    QObject,
    QTranslator,
    QUrl,
    Signal,
    Slot,
)
from PySide6.QtGui import QGuiApplication, QIcon, QUndoStack
from PySide6.QtQml import QmlElement, QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from xkbeditor.getchar import getchar
from xkbeditor.globals import APP_DIR
from xkbeditor.qt.table import *
from xkbeditor.qt.types import SymbolsFile
from xkbeditor.qt.undoStack import *

QML_IMPORT_NAME = "xkbeditor"
QML_IMPORT_MAJOR_VERSION = 2


# pyright: reportUnannotatedClassAttribute=false
@QmlElement
class Bridge(QObject):
    fileChanged = Signal()
    error = Signal(str)
    notify = Signal(str)

    def __init__(self):
        super().__init__()

        self._file = SymbolsFile(parent=self)
        self._undoStack = QUndoStack(self)

        _ = self.fileChanged.connect(self._file.variantChanged.emit)
        _ = self._file.fileLoaded.connect(self._undoStack.clear)
        _ = self._file.error.connect(self.error.emit)
        _ = self.error.connect(self.print)

    @Property(SymbolsFile, notify=fileChanged)
    def file(self):
        return self._file

    undoStackChanged = Signal()
    @Property(QObject, notify=undoStackChanged)
    def undoStack(self):
        return self._undoStack

    @Slot(str)
    def copyText(self, text: str):
        QGuiApplication.clipboard().setText(text)
        self.notify.emit(self.tr(f"Copied: {text}"))

    @Slot(str, result=str)
    def getSymbolChar(self, str: str):
        return getchar(str)

    @Slot()
    def loadTestVariant(self):
        self._file.load("/usr/share/xkeyboard-config-2/symbols/us")
        self._file.path = "/home/damglador/.config/xkb/symbols/test"  # pyright: ignore[reportAttributeAccessIssue]

    @Slot()
    def newFile(self):
        self._file.clear()
        self.fileChanged.emit()

    @Slot(str)
    def print(self, message: str):
        print(message)

    @Slot(result=str)
    def getLicenseText(self):
        with open(f"{APP_DIR}/../LICENSE", "r") as file:
            return str(file.read())


def main():
    """Initializes and manages the application execution"""
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    app.setDesktopFileName("xkb-editor")
    app.setApplicationName("Xkb Editor")
    app.setOrganizationName("damglador")
    app.setWindowIcon(QIcon.fromTheme("keyboard"))

    translator = QTranslator()
    if translator.load(QLocale(), "xkbeditor", "_", f"{APP_DIR}/translations"):
        QCoreApplication.installTranslator(translator)

    """Needed to close the app with Ctrl+C"""
    _ = signal.signal(signal.SIGINT, signal.SIG_DFL)

    """Needed to get proper KDE style outside of Plasma"""
    if not os.environ.get("QT_QUICK_CONTROLS_STYLE"):
        os.environ["QT_QUICK_CONTROLS_STYLE"] = "org.kde.desktop"

    url = QUrl(f"file://{APP_DIR}/qt/qml/Main.qml")
    engine.addImportPath(f"{APP_DIR}/qt/qml/")
    engine.load(url)

    if len(engine.rootObjects()) == 0:
        sys.exit()

    _ = app.exec()


if __name__ == "__main__":
    main()
