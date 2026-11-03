#include <cstdint>
#include <qobject.h>
#include <xkbcommon/xkbcommon-keysyms.h>
#include <xkbcommon/xkbcommon.h>

#define s QStringLiteral

xkb_keysym_t keysymFromName(const QString &name) {
    const QByteArray utf8 = name.toUtf8();
    return xkb_keysym_from_name(utf8.constData(), XKB_KEYSYM_NO_FLAGS);
}

QString keysymToString(const xkb_keysym_t keysym) {
    const uint32_t utf32 = xkb_keysym_to_utf32(keysym);
    if (utf32 == 0) {
        return QString();
    }
    const char32_t character = static_cast<char32_t>(utf32);
    return QString::fromUcs4(&character, 1);
}

QString getchar(QString input) {
    if (input.length() == 1) {
        return input;
    }
    xkb_keysym_t keysym = keysymFromName(input);
    switch (keysym) {
        case XKB_KEY_dead_tilde:
            return s("˜");
        case XKB_KEY_dead_diaeresis:
            return s("¨");
        case XKB_KEY_dead_circumflex:
            return s("ˆ");
        case XKB_KEY_dead_doubleacute:
            return s("˝");
        case XKB_KEY_dead_macron:
            return s("ˉ");
        case XKB_KEY_dead_horn:
            return s(" ̛");
        case XKB_KEY_dead_ogonek:
            return s("˛");
        case XKB_KEY_dead_breve:
            return s("˘");
        case XKB_KEY_dead_abovedot:
            return s(" ̇");
        case XKB_KEY_dead_belowdot:
            return s(" ̣");
        case XKB_KEY_dead_hook:
            return s(" ̉");
        case XKB_KEY_dead_abovering:
            return s("˚");
        case XKB_KEY_dead_caron:
            return s("ˇ");
        case XKB_KEY_dead_stroke:
            return s("ⱥ/ᵽ");
        case XKB_KEY_dead_grave:
            return s("ˋ");
        case XKB_KEY_dead_acute:
            return s("ˊ");
        case XKB_KEY_dead_iota:
            return s("ᶥ");
        case XKB_KEY_dead_cedilla:
            return s("¸");
    }
    if (input.startsWith(s("dead_"))) {
        return s("N/A");
    }
    return keysymToString(keysymFromName(input));
}
