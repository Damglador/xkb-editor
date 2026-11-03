#include <QTest>
#include <qlogging.h>
#include <qobject.h>
#include <qtestcase.h>
#include <qtmetamacros.h>
#include "Types/Include.h"

using namespace Qt::Literals::StringLiterals;

class TestInclude : public QObject {
    Q_OBJECT
private Q_SLOTS:
    void initTestCase() {
        qDebug("Testing Include class");
    }
    void testToStringPath() {
        QVERIFY(true);
        auto include = Include(u"realPath"_s);
        auto string = include.toString();
        QCOMPARE(string, u"realPath"_s);
    }
    void testToStringFull() {
        QVERIFY(true);
        auto include = Include(u"realPath"_s, u"realVariant"_s);
        auto string = include.toString();
        QCOMPARE(string, u"realPath(realVariant)"_s);
    }
    void testFromStringToStringPath() {
        QVERIFY(true);
        auto include = Include::fromString(u"realPath"_s);
        auto string = include->toString();

        QCOMPARE(include->path(), u"realPath"_s);
        QCOMPARE(string, u"realPath"_s);
    }
    void testFromStringToStringFull() {
        QVERIFY(true);
        auto include = Include::fromString(u"realPath(realVariant)"_s);
        auto string = include->toString();

        QCOMPARE(include->path(), u"realPath"_s);
        QCOMPARE(include->variant(), u"realVariant"_s);
        QCOMPARE(string, u"realPath(realVariant)"_s);
    }
    void testFromStringEmpty() {
        QVERIFY(true);
        auto include = Include::fromString(u""_s);

        QCOMPARE(include, nullptr);
    }

};

QTEST_GUILESS_MAIN(TestInclude)
#include "Include.moc"
