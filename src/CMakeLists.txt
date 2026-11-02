add_executable(xkb-editor)

ecm_add_qml_module(xkb-editor
    URI
    xkbeditor
)

target_sources(xkb-editor
    PRIVATE
    main.cpp
    Bridge.cpp
    Bridge.h
)

ecm_target_qml_sources(xkb-editor
    SOURCES
    qml/Main.qml
    qml/Keyboard/Keyboard_ANSI.qml
    qml/Keyboard/Keypad.qml
    qml/Keyboard/Key.qml
    qml/Keyboard/AbstractKey.qml
    qml/Preview/CharLabel.qml
    qml/Preview/PreviewKey.qml
    qml/Preview/PreviewKeyDelegate.qml
    qml/Preview/PreviewKeyboard.qml
    qml/EditorComponents/FlagsChips.qml
    qml/EditorComponents/IncludeMenu.qml
    qml/EditorComponents/IncludesChips.qml
    qml/KeysymTable.qml
    qml/MenuBar.qml
    qml/ImportDialog.qml
    qml/EditorPage.qml
    qml/VariantEditor.qml
    qml/About.qml
    qml/VariantsList.qml
)

set(QML_SETTINGS
    qml/Settings/Paths.qml
    qml/Settings/GeneralSettings.qml
    qml/Settings/ViewSettings.qml
)

set_source_files_properties(${QML_SETTINGS}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

ecm_target_qml_sources(xkb-editor
    SOURCES ${QML_SETTINGS}
    PATH Settings
)

target_link_libraries(xkb-editor
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Widgets
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
)

install(TARGETS xkb-editor ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
