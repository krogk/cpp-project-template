cmake_minimum_required(VERSION 3.16)

# Set standard
set(CMAKE_CXX_STANDARD 20)
# Standard is required
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Set Extensions
set(CMAKE_CXX_EXTENSIONS OFF)
# Set to Dev mode on i.e enable all analysers
set(DEV_MODE TRUE CACHE BOOL "Enable Dev mode")

# Compiler choice

# Compile options
add_compile_options(-g -Wall -Wextra -Werror -Wshadow -Wpedantic -Wconversion)

# Set project info
project(
	cpp-template-project
	VERSION 0.0.1
	DESCRIPTION "Lightweight C++ Project Template"
	HOMEPAGE_URL "%%https://github.com/krogk/cpp-project-template%%"
	LANGUAGES CXX C)

# Conan
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

# Add cmake files dir
add_subdirectory(cmake)
# Add src dir
add_subdirectory(src)
# Add docs dir