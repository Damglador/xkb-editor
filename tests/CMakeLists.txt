include(ECMAddTests)

include_directories(${CMAKE_SOURCE_DIR}/src)

ecm_add_test(Types/Include.cpp
    ${CMAKE_SOURCE_DIR}/src/Types/Include.h
    TEST_NAME text-types-variant
    LINK_LIBRARIES Qt6::Test Qt6::Core
)

ecm_add_test(Types/Variant.cpp
    ${CMAKE_SOURCE_DIR}/src/Types/Variant.h
    ${CMAKE_SOURCE_DIR}/src/Types/Include.h
    TEST_NAME text-types-variant
    LINK_LIBRARIES Qt6::Test Qt6::Core
)
