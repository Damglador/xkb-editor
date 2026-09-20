pragma Singleton

import QtCore

Settings {
    category: "View"
    location: General.stateFile
    property bool showLegends: true
    property bool showFallbacks: true
    property bool variantsSidebar: true
}
