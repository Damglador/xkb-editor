pragma Singleton

import QtCore

Settings {
    category: "General"
    location: configFile
    readonly property url configFile: StandardPaths.standardLocations(StandardPaths.GenericConfigLocation)[0] + "/xkb-editor.conf"
    readonly property url stateFile: StandardPaths.standardLocations(StandardPaths.GenericStateLocation)[0] + "/xkb-editor.conf"
    property bool showLegends: true
    property bool showFallbacks: true
    property bool variantsSidebar: true
}
