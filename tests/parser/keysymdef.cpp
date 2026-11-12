#include <QObject>
#include <QString>
#include <QTest>
#include <QDebug>

#include "parser/keysymdef_parser.h"

using namespace Qt::Literals::StringLiterals;

class TestKeysymdefParser : public QObject {
    Q_OBJECT
private Q_SLOTS:
    void test() {
        auto items = tableFromFile("/usr/include/X11/keysymdef.h");
        // qDebug().noquote() << itemsToString(items);
        QCOMPARE(items[2].name, "XK_VoidSymbol");
        QCOMPARE(items[2].keysym, "0xffffff");
        QCOMPARE(items[2].comment, "Void symbol");
    }
};

QTEST_APPLESS_MAIN(TestKeysymdefParser)
#include "keysymdef.moc"
