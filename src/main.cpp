#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QIcon>
#include <QQuickStyle>
#include <KLocalization>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KIconTheme>
#include <kaboutdata.h>
#include <qapplication.h>
#include <qbitarray.h>

#define s QStringLiteral

int main(int argc, char *argv[])
{
    KIconTheme::initTheme();
    QApplication app(argc, argv);
    QApplication::setOrganizationName(QStringLiteral("damglador"));
    QApplication::setApplicationName(QStringLiteral("Xkb Editor"));
    QApplication::setDesktopFileName(QStringLiteral("xkb-editor"));
    QApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("input-keyboard")));

    KAboutData aboutData(s("xkb-editor"), s("Xkb Editor"), s("0.1.0"));
    aboutData.setShortDescription(s("View and edit xkb layouts"));
    aboutData.setHomepage(s("https://github.com/Damglador/xkb-editor"));
    aboutData.setCopyrightStatement(s("Copyright © 2026 Vsevolod «Damglador» Stopchanskyi"));
    aboutData.setLicense(KAboutLicense::GPL_V3);
    KAboutData::setApplicationData(aboutData);


    QApplication::setStyle(QStringLiteral("breeze"));
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule("xkbeditor", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
