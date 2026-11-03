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
};

QTEST_GUILESS_MAIN(TestVariant)
#include "Variant.moc"
