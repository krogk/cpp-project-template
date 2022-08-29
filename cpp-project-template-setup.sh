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
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
# Libs
sudo apt-get install libboost-all-dev -y
# Profilers
sudo apt install valgrind -y

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