cmake_minimum_required(VERSION 3.16.3)

project(enneade CXX) 

if(NOT CMAKE_BUILD_TYPE)
    message(STATUS "No build type selected, defaulting to Debug")
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type")
endif()

if(NOT DEFINED MPI)
    message(STATUS "MPI not specified, defaulting to ON")
    set(MPI ON CACHE BOOL "Use MPI libraries")
endif()

if(NOT DEFINED BUILD_JARS)
    message(STATUS "BUILD_JARS not specified, defaulting to ON")
    set(BUILD_JARS ON CACHE BOOL "Enable building JAR files")
endif()

if(NOT DEFINED TESTING)
    message(STATUS "TESTING not specified, defaulting to ON")
    set(TESTING ON CACHE BOOL "Enable unit tests")
endif()

if(NOT DEFINED C11)
    message(STATUS "C11 not specified, defaulting to OFF")
    set(C11 OFF CACHE BOOL "Disable C++11 standard")
endif()

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


if( MSVC)
    # Enable RTTI (Run-Time Type Information)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /GR ")
endif()

if(DEFINED MPI)
    set(MPI_CXX_INCLUDE_PATH "C:/Program Files (x86)/Microsoft SDKs/MPI/Include")
    set(MPI_CXX_LIBRARIES "C:/Program Files (x86)/Microsoft SDKs/MPI/Lib/x64/msmpi.lib")
    set(MPIEXEC "C:/Program Files/Microsoft MPI/Bin/mpiexec.exe")
endif()

# Use Khiops 
include(FetchContent)
FetchContent_Declare(
    khiops
    GIT_REPOSITORY "https://github.com/KhiopsML/khiops.git"
    GIT_TAG "10.7.0-b.0")

set(BUILD_JARS ON CACHE BOOL "Enable building JAR files" FORCE)

FetchContent_MakeAvailable(khiops)

FetchContent_GetProperties(khiops SOURCE_DIR KHIOPS_SOURCE_DIR)

add_subdirectory(src)

set(KHIOPS_SOURCE_DIR ${KHIOPS_SOURCE_DIR} CACHE PATH "Khiops source path")

add_subdirectory(tests)

