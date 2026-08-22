#!/usr/bin/env python3

import os
import signal
import sys

from PySide6.QtCore import QObject, QUrl, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QmlElement, QQmlApplicationEngine

from . import xkb
from .getchar import getchar

QML_IMPORT_NAME = "project"
QML_IMPORT_MAJOR_VERSION = 2

variant = xkb.getVariant("ua", "unicode")

@QmlElement
class Bridge(QObject):
    @Slot(str, int, result=str)
    def getKeyChar(self, keycode: str, layer: int):
        return getchar(variant.getSymbol(keycode, layer))

    @Slot(str, int, result=str)
    def getKeyCharFallback(self, keycode: str, layer: int):
        return getchar(variant.getSymbolOrFallback(keycode, layer, False))


def main():
    """Initializes and manages the application execution"""
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

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
