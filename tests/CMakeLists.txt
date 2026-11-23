include(ECMAddTests)

include_directories(${CMAKE_SOURCE_DIR}/src)

ecm_add_test(Types/test_Include.cpp
    TEST_NAME test-types-include
    LINK_LIBRARIES
    xkb-types
    Qt6::Test
    Qt6::Core
)

ecm_add_test(Types/test_Variant.cpp
    TEST_NAME test-types-variant
    LINK_LIBRARIES
    xkb-types
    Qt6::Test
    Qt6::Core
)

ecm_add_test(parser/test_xkb.cpp
    TEST_NAME test-parser-xkb
    LINK_LIBRARIES
    xkb-parser
    xkb-types
    Qt6::Test
    Qt6::Core
)

ecm_add_test(parser/test_keysymdef.cpp
    TEST_NAME test-parser-keysymdef
    LINK_LIBRARIES
    xkb-parser
    xkb-types
    Qt6::Test
    Qt6::Core
)
