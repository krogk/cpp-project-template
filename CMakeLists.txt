cmake_minimum_required(VERSION 3.16)

# Set standard 
set(CMAKE_CXX_STANDARD 20)
# Set Extensions
set(CMAKE_CXX_EXTENSIONS OFF)
# Set to Dev mode on i.e enable all analysers
set(DEV_MODE TRUE CACHE BOOL "Enable Dev mode")

# Set project info
project(
	cpp-template-project
	VERSION 0.0.1
	DESCRIPTION "Lightweight C++ Project Template"
	HOMEPAGE_URL "%%myurl%%"
	LANGUAGES CXX C)

# Add src dir
add_subdirectory(src)

