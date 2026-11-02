import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.coreaddons // Required for AboutData which is passed to aboutData

Kirigami.ApplicationWindow {
    title: aboutPage.title
    transientParent: null // Show as a separate window in taskbar
    width: Kirigami.Units.gridUnit * 36
    height: Kirigami.Units.gridUnit * 30
    pageStack.initialPage: FormCard.AboutPage {
        id: aboutPage
        globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
        getInvolvedUrl: "https://github.com/Damglador/xkb-editor"
        donateUrl: ""
        aboutData: AboutData
    }
}
