import org.kde.kirigami as Kirigami

Kirigami.Dialog {
    title: qsTr("About")
    width: window.width / 2
    contentItem: Kirigami.AboutPage {
        id: aboutPage
        getInvolvedUrl: "https://github.com/Damglador/xkb-editor"
        aboutData: {
            "displayName": "Xkb Editor",
            "version": "1",
            "componentName": "xkbeditor",
            "desktopFileName": "xkbeditor",
            "shortDescription": "View and edit xkb layouts",
            "homepage": "https://github.com/Damglador/xkb-editor",
            "bugAddress": "https://github.com/Damglador/xkb-editor/issues",
            "authors": [
                {
                    "name": "Vsevolod «Damglador» Stopchanskyi",
                    "task": "Code, UI",
                    "emailAddress": "damglador@gmail.com",
                    "webAddress": "https://damglador.com",
                    "ocsUsername": "damglador"
                }
            ],
            "copyrightStatement": "© 2026 Vsevolod «Damglador» Stopchanskyi",
            "licenses": [
                {
                    "name": "GPL v3",
                    "text": bridge.license,
                    "spdx": "GPL-3.0"
                }
            ]
        }
    }
}
