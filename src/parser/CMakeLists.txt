include_directories(..)

add_library(xkb-parser
    STATIC
    keysymdef_parser.cpp
    keysymdef_parser.h
)
