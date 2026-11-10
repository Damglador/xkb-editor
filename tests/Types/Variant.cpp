#include <QTest>
#include <qlogging.h>
#include <qobject.h>
#include <qtestcase.h>
#include <qtmetamacros.h>
#include "Types/Variant.h"

using namespace Qt::Literals::StringLiterals;

class TestVariant : public QObject {
    Q_OBJECT
private Q_SLOTS:
    void initTestCase() {
        qDebug("Testing Variant class");
    }
    void testProperties() {
        QVERIFY(true);
        Variant variant;
        variant.setId(u"validId"_s);
        variant.setName(u"validName"_s);
        variant.setKeytype(u"validKeytype"_s);
        variant.setSource(u"validSource"_s);

        QCOMPARE(variant.id(), u"validId"_s);
        QCOMPARE(variant.name(), u"validName"_s);
        QCOMPARE(variant.keytype(), u"validKeytype"_s);
        QCOMPARE(variant.source(), u"validSource"_s);
    }
    void testFlags() {
        Variant variant;
        variant.addFlag(u"default"_s);
        variant.addFlag(u"partial"_s);
        QCOMPARE(variant.flags().join(u", "_s), u"default, partial"_s);
    }
    void testSymbols() {
        Variant variant;
        variant.setSymbol(u"AE12"_s, 1, u"E"_s);
        QCOMPARE(variant.getSymbol(u"AE12"_s, 1), u"E"_s);
        QCOMPARE(variant.getSymbol(u"AE13"_s, 1), u""_s);
        QCOMPARE(variant.getSymbol(u"AE12"_s, 2), u""_s);

        variant.setSymbol(u"AE12"_s, 4, u"Ї"_s);
        QCOMPARE(variant.getSymbol(u"AE12"_s, 4), u"Ї"_s);
        QCOMPARE(variant.getSymbol(u"AE12"_s, 3), u""_s);
    }
};

QTEST_APPLESS_MAIN(TestVariant)
#include "Variant.moc"
