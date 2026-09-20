pragma Singleton

import QtCore

Settings {
    category: "View"
    location: StandardPaths.standardLocations(StandardPaths.GenericStateLocation)[0] + "/xkb-editor.conf"
    property bool showLegends: true
    property bool showFallbacks: true
    property bool variantsSidebar: true
}
