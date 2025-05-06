include(FetchContent)

FetchContent_Declare(
    googletest
    GIT_REPOSITORY "https://github.com/google/googletest.git"
    GIT_TAG "v1.13.0"
)
FetchContent_MakeAvailable(googletest)

# Workaround for windows: https://github.com/actions/virtual-environments/issues/5900
if(CMAKE_BUILD_TYPE STREQUAL "Release")
set_property(TARGET gtest PROPERTY MSVC_RUNTIME_LIBRARY MultiThreaded)
set_property(TARGET gtest_main PROPERTY MSVC_RUNTIME_LIBRARY MultiThreaded)
else()
set_property(TARGET gtest PROPERTY MSVC_RUNTIME_LIBRARY MultiThreadedDebug)
set_property(TARGET gtest_main PROPERTY MSVC_RUNTIME_LIBRARY MultiThreadedDebug)
endif()


enable_testing()


file(GLOB_RECURSE test_files *.h *.cpp)

add_executable(${PROJECT_NAME}_test ${test_files})

set_khiops_options(${PROJECT_NAME}_test)

target_include_directories(${PROJECT_NAME}_test PRIVATE 
    ${PROJECT_SOURCE_DIR}/tests
    ${PROJECT_SOURCE_DIR}/src
    ${KHIOPS_SOURCE_DIR}/src/Learning/KWDataUtils
    ${KHIOPS_SOURCE_DIR}/src/Parallel/PLMPI
)

target_link_libraries(${PROJECT_NAME}_test
    PRIVATE
    enneade_core
    GTest::gtest_main
)


include(GoogleTest)
gtest_discover_tests(${PROJECT_NAME}_test)