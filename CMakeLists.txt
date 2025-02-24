cmake_minimum_required(VERSION 3.16.3)

project(Enneade CXX)

# Use Khiops 
include(FetchContent)
FetchContent_Declare(
    khiops
    GIT_REPOSITORY "https://github.com/KhiopsML/khiops.git"
    GIT_TAG "10.1.0")

FetchContent_MakeAvailable(khiops)


file(GLOB files  ${PROJECT_SOURCE_DIR}/src/*cpp  ${PROJECT_SOURCE_DIR}/src/*cc ${PROJECT_SOURCE_DIR}/src/*h )
add_executable(enneade  ${files} )
set_khiops_options(enneade)

# Link with Khiops libraries
target_link_libraries(enneade KMDRRuleLibrary KWLearningProblem)