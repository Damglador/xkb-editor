include_directories(..) # needed macros.h

add_library(xkb-types
    STATIC
    Enums.h
    Include.h
    KeyProps.h
    Variant.h
    List.h
    VariantsList.h
)

target_link_libraries(xkb-types
    PRIVATE
    Qt6::Core
    Qt6::Quick
)
