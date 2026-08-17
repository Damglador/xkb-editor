
from os import environ, path

# From xkbcli info
XKB_CONFIG_ROOT = environ.get("XKB_CONFIG_ROOT") or "/usr/share/xkeyboard-config-2"
XKB_CONFIG_LEGACY_ROOT = "/usr/share/X11/xkb"
XKB_CONFIG_EXTRA_PATH = environ.get("XKB_CONFIG_EXTRA_PATH") or "/etc/xkb"
XKB_CONFIG_UNVERSIONED_EXTENSIONS_PATH = environ.get("XKB_CONFIG_UNVERSIONED_EXTENSIONS_PATH") or "/usr/share/xkeyboard-config.d"
XKB_CONFIG_VERSIONED_EXTENSIONS_PATH = environ.get("XKB_CONFIG_VERSIONED_EXTENSIONS_PATH") or "/usr/share/xkeyboard-config-2.d"

XKB_DEFAULT_RULES = environ.get("XKB_DEFAULT_RULES") or "evdev"
XKB_DEFAULT_MODEL = environ.get("XKB_DEFAULT_MODEL") or "pc105"

HOME = environ.get("HOME") or path.expanduser('~')
XDG_CONFIG_HOME = environ.get("XDG_CONFIG_HOME") or path.join(HOME, ".config")

XKB_INCLUDE_PATHS: list[str] = []

for xkbpath in [
    XKB_CONFIG_ROOT,
    XKB_CONFIG_LEGACY_ROOT,
    XKB_CONFIG_EXTRA_PATH,
    XKB_CONFIG_UNVERSIONED_EXTENSIONS_PATH,
    XKB_CONFIG_VERSIONED_EXTENSIONS_PATH,
    path.join(XDG_CONFIG_HOME, "xkb") ]:
        if path.isdir(xkbpath):
            XKB_INCLUDE_PATHS.append(xkbpath)
