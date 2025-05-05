include(FetchContent)

FetchContent_Declare(
    googletest
    GIT_REPOSITORY "https://github.com/google/googletest.git"
    GIT_TAG "v1.13.0"
)
FetchContent_MakeAvailable(googletest)

# Required for MSVC runtime flags
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

enable_testing()

# Use Khiops 
FetchContent_Declare(
    khiops
    GIT_REPOSITORY "https://github.com/KhiopsML/khiops.git"
    GIT_TAG "10.7.0-b.0")

set(BUILD_JARS ON CACHE BOOL "Enable building JAR files" FORCE)

FetchContent_MakeAvailable(khiops)


# Get the path to the Khiops source directory
FetchContent_GetProperties(khiops SOURCE_DIR KHIOPS_SOURCE_DIR)

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