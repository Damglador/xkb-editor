#include <QObject> // Need QObject for macros to work

// Use Q_GADGET for lightweight meta-data support
class Enums
{
    Q_GADGET

public:
    // https://www.charvolant.org/doug/xkb/html/node5.html
    enum Flag {
        DEFAULT,
        PARTIAL,
        HIDDEN,
        ALPHANUMERIC_KEYS,
        MODIFIER_KEYS,
        KEYPAD_KEYS,
        FUNCTION_KEYS,
        ALTERNATE_GROUP,
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
