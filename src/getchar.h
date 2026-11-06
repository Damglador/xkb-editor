#include <qobject.h>
#include <xkbcommon/xkbcommon-keysyms.h>
#include <xkbcommon/xkbcommon.h>

#define s QStringLiteral

xkb_keysym_t keysymFromName(const QString &name);

QString keysymToString(const xkb_keysym_t keysym);

QString xkb_getchar(QString input);
