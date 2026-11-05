include(ECMAddTests)

include_directories(${CMAKE_SOURCE_DIR}/src)

ecm_add_test(Types/Include.cpp
    TEST_NAME test-types-include
    LINK_LIBRARIES xkb-types Qt6::Test Qt6::Core
)

ecm_add_test(Types/Variant.cpp
    TEST_NAME test-types-variant
    LINK_LIBRARIES xkb-types Qt6::Test Qt6::Core
)
