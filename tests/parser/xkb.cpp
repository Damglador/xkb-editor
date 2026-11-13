#include <QObject>
#include <QString>
#include <QTest>

#include "parser/xkb.h"

using namespace Qt::Literals::StringLiterals;

class TestXkbParser : public QObject {
    Q_OBJECT
private Q_SLOTS:
    void test() {
        auto variants = variantsFromFile(u"/usr/share/xkeyboard-config-2/symbols/us"_s);
        qDebug() << variants[0]->id();
        qDebug() << variants[0]->name();
        qDebug() << variants[0]->flags();
        qDebug().noquote() << variants[0]->toXkb().prepend(u"\n");
    }
};

QTEST_APPLESS_MAIN(TestXkbParser)
#include "xkb.moc"
