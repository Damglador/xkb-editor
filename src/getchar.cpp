#include <QString>
#include <cstdint>
#include <xkbcommon/xkbcommon-keysyms.h>
#include <xkbcommon/xkbcommon.h>

#define s QStringLiteral

// Creating these is expensive so just store one instance for everything
xkb_context* xkb_context_default = xkb_context_new(XKB_CONTEXT_NO_FLAGS);
xkb_keymap* xkb_keymap_default = xkb_keymap_new_from_names2(
    xkb_context_default, nullptr, XKB_KEYMAP_FORMAT_TEXT_V2, XKB_KEYMAP_COMPILE_NO_FLAGS);

xkb_keysym_t keysymFromName(const QString& name) {
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

QString xkb_getchar(const QString input) {
    if (input.length() == 1) {
        return input;
    }
    xkb_keysym_t keysym = keysymFromName(input);
    switch (keysym) {
    case XKB_KEY_dead_tilde: return s("˜");
    case XKB_KEY_dead_diaeresis: return s("¨");
    case XKB_KEY_dead_circumflex: return s("ˆ");
    case XKB_KEY_dead_doubleacute: return s("˝");
    case XKB_KEY_dead_macron: return s("ˉ");
    case XKB_KEY_dead_horn: return s(" ̛");
    case XKB_KEY_dead_ogonek: return s("˛");
    case XKB_KEY_dead_breve: return s("˘");
    case XKB_KEY_dead_abovedot: return s(" ̇");
    case XKB_KEY_dead_belowdot: return s(" ̣");
    case XKB_KEY_dead_hook: return s(" ̉");
    case XKB_KEY_dead_abovering: return s("˚");
    case XKB_KEY_dead_caron: return s("ˇ");
    case XKB_KEY_dead_stroke: return s("ⱥ/ᵽ");
    case XKB_KEY_dead_grave: return s("ˋ");
    case XKB_KEY_dead_acute: return s("ˊ");
    case XKB_KEY_dead_iota: return s("ᶥ");
    case XKB_KEY_dead_cedilla: return s("¸");
    }
    if (input.startsWith(s("dead_"))) {
        return s("N/A");
    }
    return keysymToString(keysymFromName(input));
}

xkb_keycode_t xkb_get_keycode(const QString keyname) {
    return xkb_keymap_key_by_name(xkb_keymap_default, keyname.toLocal8Bit().data());
}

QString xkb_get_keyname(const xkb_keycode_t keycode) {
    return QString::fromLocal8Bit(xkb_keymap_key_get_name(xkb_keymap_default, keycode));
}
