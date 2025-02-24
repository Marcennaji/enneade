[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

Khiops enneade is **no longer supported**.

# DEPRECATED Khiops enneade
 
Khiops Enneade is a tool which produces a clustering model using a modified version of the K-Means algorithm. Khiops Enneade is available both in user interface mode and in batch mode, such that it can easily be embedded as a software component in a data mining deployment project.

Khiops Enneade belongs to the Khiops family.

## How to build enneade

You need to install [CMake](https://cmake.org/). Then run the following command:
```bash
cmake -B build -S . -D CMAKE_BUILD_TYPE=Release
cmake --build build --target enneade
```

This source code is based on the [Khiops](https://github.com/KhiopsML/khiops) libraries (supported version is 10.1.0). 