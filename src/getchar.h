#include <qobject.h>
#include <xkbcommon/xkbcommon-keysyms.h>
#include <xkbcommon/xkbcommon.h>

extern xkb_context* xkb_context_default;
extern xkb_keymap* xkb_keymap_default;

QString keysymToString(const xkb_keysym_t keysym);
xkb_keysym_t keysymFromName(const QString &name);

QString xkb_getchar(const QString input);

xkb_keycode_t xkb_get_keycode(const QString keyname);
QString xkb_get_keyname(const xkb_keycode_t keycode);
