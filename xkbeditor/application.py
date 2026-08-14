#!/usr/bin/env python3

import os
import signal
import sys

from PySide6.QtCore import QObject, QUrl, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QmlElement, QQmlApplicationEngine

from . import parser

QML_IMPORT_NAME = "project"
QML_IMPORT_MAJOR_VERSION = 2

variant = parser.getVariantFromFile("/usr/share/xkeyboard-config-2/symbols/us", "basic")

@QmlElement
class Bridge(QObject):
    @Slot(str, int, str, result=str)
    def getKey(self, keycode, layer, oldLabel):
        if keycode:
            if variant is not None:
                return variant.getSymbol(keycode, layer)
            return keycode
        return oldLabel


def main():
  """Initializes and manages the application execution"""
  app = QGuiApplication(sys.argv)
  engine = QQmlApplicationEngine()

  """Needed to close the app with Ctrl+C"""
  signal.signal(signal.SIGINT, signal.SIG_DFL)

  """Needed to get proper KDE style outside of Plasma"""
  if not os.environ.get("QT_QUICK_CONTROLS_STYLE"):
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "org.kde.desktop"

  base_path = os.path.abspath(os.path.dirname(__file__))
  url = QUrl(f"file://{base_path}/qml/Main.qml")
  engine.load(url)

  if len(engine.rootObjects()) == 0:
    sys.exit()

  app.exec()


if __name__ == "__main__":
  main()
