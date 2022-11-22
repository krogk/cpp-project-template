# CMake version required
cmake_minimum_required(VERSION 3.16)

# Create a library
add_library(SqrtLibrary sqrt.cpp)
# add_library(SqrtLibrary SHARED sqrt.cpp) # Builds a shared library
# add_library(SqrtLibrary STATIC sqrt.cpp) # Builds a static library

# Link other libraties if neccessary 
target_link_libraries(SqrtLibrary pthread)

# Include the directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Add unit test
add_subdirectory(ut)