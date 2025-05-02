
# Use Khiops 
include(FetchContent)
FetchContent_Declare(
    khiops
    GIT_REPOSITORY "https://github.com/KhiopsML/khiops.git"
    GIT_TAG "10.7.0-b.0")

set(BUILD_JARS ON CACHE BOOL "Enable building JAR files" FORCE)

FetchContent_MakeAvailable(khiops)


# Get the path to the Khiops source directory
FetchContent_GetProperties(khiops SOURCE_DIR KHIOPS_SOURCE_DIR)

file(GLOB_RECURSE core_files
    ${PROJECT_SOURCE_DIR}/src/domain/*.cpp ${PROJECT_SOURCE_DIR}/src/domain/*.h
    ${PROJECT_SOURCE_DIR}/src/infrastructure/*.cpp ${PROJECT_SOURCE_DIR}/src/infrastructure/*.h
    ${PROJECT_SOURCE_DIR}/src/application/*.cpp ${PROJECT_SOURCE_DIR}/src/application/*.h
    ${PROJECT_SOURCE_DIR}/src/ui/*.cpp ${PROJECT_SOURCE_DIR}/src/ui/*.h
    ${PROJECT_SOURCE_DIR}/src/utils/*.cpp ${PROJECT_SOURCE_DIR}/src/utils/*.h
)


# create an enneade static library
add_library(${PROJECT_NAME}_core STATIC ${core_files})

target_include_directories(${PROJECT_NAME}_core PRIVATE 
    ${PROJECT_SOURCE_DIR}/src 
    ${KHIOPS_SOURCE_DIR}/src/Learning/KWDataUtils  
    ${KHIOPS_SOURCE_DIR}/src/Parallel/PLMPI
    )

set_khiops_options(${PROJECT_NAME}_core)

target_link_libraries(${PROJECT_NAME}_core KMDRRuleLibrary KWLearningProblem PLMPI)

# create an executable for the main function
add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_core)
set_khiops_options(${PROJECT_NAME})





