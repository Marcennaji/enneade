cmake_minimum_required(VERSION 3.16.3)

project(enneade CXX) 

set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable RTTI (Run-Time Type Information)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /GR ")

set(MPI_CXX_INCLUDE_PATH "C:/Program Files (x86)/Microsoft SDKs/MPI/Include")
set(MPI_CXX_LIBRARIES "C:/Program Files (x86)/Microsoft SDKs/MPI/Lib/x64/msmpi.lib")
set(MPIEXEC "C:/Program Files/Microsoft MPI/Bin/mpiexec.exe")

add_subdirectory(src)

set(KHIOPS_SOURCE_DIR ${KHIOPS_SOURCE_DIR} CACHE PATH "Khiops source path")

add_subdirectory(tests)

