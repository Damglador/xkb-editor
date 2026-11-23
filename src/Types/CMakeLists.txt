include_directories(..) # needed macros.h

add_library(xkb-types
    STATIC
    Enums.h
    Include.h
    Include.cpp
    KeyProps.h
    Variant.h
    Variant.cpp
    List.h
    IncludesList.h
    VariantsList.h
    ../getchar.cpp
    ../getchar.h
)

target_link_libraries(xkb-types
    PRIVATE
    xkb-parser
    xkbcommon
    Qt6::Core
    Qt6::Quick
)
