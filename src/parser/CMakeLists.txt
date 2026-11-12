include_directories(..)

add_library(xkb-parser
    STATIC
    keysymdef_parser.cpp
    keysymdef_parser.h
    xkb.cpp
    xkb.h
)

target_link_libraries(xkb-parser
    PRIVATE
    xkb-types
    Qt6::Core
)
