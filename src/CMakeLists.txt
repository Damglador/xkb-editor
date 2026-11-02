add_executable(xkb-editor)

ecm_add_qml_module(xkb-editor
    URI
    xkbeditor
)

target_sources(xkb-editor
    PRIVATE
    main.cpp
)

ecm_target_qml_sources(xkb-editor
    SOURCES
    Main.qml
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
