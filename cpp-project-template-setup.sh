#!/bin/bash

CalledFromDir=$(pwd)

# Update & Upgrade apt
sudo apt update -y
sudo apt upgrade -y

# software-properties-common package gives you better control over
# your package manager by letting you add PPA (Personal Package Archive) repositories.
sudo apt install software-properties-common -y

# Linux tools
sudo apt install linux-tools-common gawk -y

# Source Control
sudo apt-get install git-all -y

# C++ Ecosystem
# Build
sudo apt-get install build-essential libtool autoconf unzip wget dkms linux-headers-$(uname -r) -y
sudo apt-get install make  -y
sudo apt-get install cmake -y
sudo apt-get install ccache -y 
# LLVM
sudo apt-get install llvm -y  
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" # TODO: This does not run when installing with readme command
sudo apt-get install clang-format -y 
# Code coverage
sudo apt-get install lcov -y  
# Libs
sudo apt-get install libboost-all-dev -y
# Profilers
sudo apt install valgrind -y
# Docs
sudo apt install doxygen -y 
sudo apt install graphviz -y
# Static analysis
sudo apt install cppcheck -y

# Pcre
sudo apt install libpcre3-dev -y
# cppcheck
cd /tmp #TODO: Stick to one folder when cloning packages
git clone https://github.com/danmar/cppcheck.git
cd cppcheck 
git checkout 2.7 
sudo make MATCHCOMPILER=yes FILESDIR=/usr/share/cppcheck HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" install
cd /tmp
rm -rf /tmp/cppcheck
sudo ldconfig
cppcheck --version

# C++ Google Test Framework - Alternativley build From source
sudo apt-get install libgtest-dev
cd /usr/src/gtest
sudo cmake CMakeLists.txt
sudo make
cd lib/
sudo cp *.a /usr/lib

### Build ###
cd ${CalledFromDir}
# Clone project template
git clone https://github.com/krogk/cpp-project-template
# Change dir to the cloned repo
cd cpp-project-template/
# Create build dir
mkdir build
# Change to build dir
cd build
# Generate CMake files
cmake ..
# Make project
make

### Test ###

# Run sqrt unit test
./src/sdk/sqrt/ut/ut-sqrt