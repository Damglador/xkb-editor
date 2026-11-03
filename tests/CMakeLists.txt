include(ECMAddTests)

ecm_add_test(Types/Include.cpp
    ${CMAKE_SOURCE_DIR}/src/Types/Include.h
    TEST_NAME types_include_test
    LINK_LIBRARIES Qt6::Test Qt6::Core
)

target_include_directories(types_include_test
    PRIVATE ${CMAKE_SOURCE_DIR}/src)

ecm_add_test(Types/Variant.cpp
    ${CMAKE_SOURCE_DIR}/src/Types/Variant.h
    ${CMAKE_SOURCE_DIR}/src/Types/Include.h
    TEST_NAME types_variant_test
    LINK_LIBRARIES Qt6::Test Qt6::Core
)

target_include_directories(types_variant_test
    PRIVATE ${CMAKE_SOURCE_DIR}/src)
