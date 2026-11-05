#pragma once

#include <QObject> // Need QObject for macros to work

// Use Q_GADGET for lightweight meta-data support
class Enums
{
    Q_GADGET
public:
    // https://www.charvolant.org/doug/xkb/html/node5.html
    enum Flag {
        DEFAULT             = 1 << 0,
        PARTIAL             = 1 << 1,
        HIDDEN              = 1 << 2,
        ALPHANUMERIC_KEYS   = 1 << 3,
        MODIFIER_KEYS       = 1 << 4,
        KEYPAD_KEYS         = 1 << 5,
        FUNCTION_KEYS       = 1 << 6,
        ALTERNATE_GROUP     = 1 << 7,
    };
    Q_ENUM(Flag)
    Q_DECLARE_FLAGS(Flags, Flag)
    Q_FLAG(Flags)

    // https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html#merge-mode-def
    enum MergeMode {
        OVERRIDE, // override is the default
        AUGMENT,
        REPLACE,
        ALTERNATE,
    };
    Q_ENUM(MergeMode)
};

Q_DECLARE_OPERATORS_FOR_FLAGS(Enums::Flags)
