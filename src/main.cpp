#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QIcon>
#include <QQuickStyle>
#include <KLocalization>
#include <KLocalizedQmlContext>
#include <KLocalizedString>
#include <KIconTheme>
#include <kaboutdata.h>
#include <qapplication.h>
#include <qbitarray.h>
#include <qcoreapplication.h>

using namespace Qt::Literals::StringLiterals;

#define APPID QStringLiteral("xkb-editor")
#define APPNAME QStringLiteral("Xkb Editor")

int main(int argc, char *argv[])
{
    KIconTheme::initTheme();
    QApplication app(argc, argv);
    QApplication::setOrganizationName(u"damglador"_s);
    QApplication::setApplicationName(APPNAME);
    QApplication::setDesktopFileName(APPID);
    QApplication::setWindowIcon(QIcon::fromTheme(u"input-keyboard"_s));

    KAboutData aboutData(APPID, APPNAME, u"0.1.0"_s);
    aboutData.setOrganizationDomain("damglador.com");
    aboutData.setDesktopFileName(APPID);
    aboutData.setShortDescription(u"View and edit xkb layouts"_s);
    aboutData.setHomepage(u"https://github.com/Damglador/xkb-editor"_s);
    aboutData.setBugAddress("https://github.com/Damglador/xkb-editor/issues");
    aboutData.setCopyrightStatement(u"Copyright © 2026 Vsevolod «Damglador» Stopchanskyi"_s);
    aboutData.setLicense(KAboutLicense::GPL_V3);
    KAboutData::setApplicationData(aboutData);


    QApplication::setStyle(u"breeze"_s);
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(u"org.kde.desktop"_s);
    }

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedQmlContext(&engine));
    engine.loadFromModule("xkbeditor", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
