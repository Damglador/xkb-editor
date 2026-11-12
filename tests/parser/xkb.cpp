#include <QObject>
#include <QString>
#include <QTest>

#include "parser/xkb.h"

using namespace Qt::Literals::StringLiterals;

class TestXkbParser : public QObject {
    Q_OBJECT
private Q_SLOTS:
    void test() {
        variantsFromFile(u"/usr/share/xkeyboard-config-2/symbols/us"_s);
    }
};

QTEST_APPLESS_MAIN(TestXkbParser)
#include "xkb.moc"
