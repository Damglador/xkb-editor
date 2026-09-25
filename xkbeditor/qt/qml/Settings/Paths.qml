pragma Singleton

import QtCore
import QtQuick

Item {
    readonly property string configFile: StandardPaths.standardLocations(StandardPaths.GenericConfigLocation)[0] + "/xkb-editor.conf"
    readonly property string stateFile: StandardPaths.standardLocations(StandardPaths.GenericStateLocation)[0] + "/xkb-editor.conf"
}
