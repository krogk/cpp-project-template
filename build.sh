#!/usr/bin/env bash


### TODO: Parse parameters
# -h help info
# -d debug
# -r release
# -j # Use # cores for build
# -c cached build
###

# Create build folder
mkdir build && cd build

# Defaults

# Compiler

# Conan
# Change the default profile to use libstdc++11
# https://docs.conan.io/en/latest/howtos/manage_gcc_abi.html#manage-gcc-abi
# https://stackoverflow.com/questions/61019721/why-cant-i-link-to-spdlog-library-installed-with-conan
conan profile update settings.compiler.libcxx=libstdc++11 default # Consider using helpers to set this automatically
# Install
conan install ..
# CMake
cmake .. 
cmake --build .
