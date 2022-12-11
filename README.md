# C++ Starter Project

[![ci](https://github.com/krogk/cpp-project-template/actions/workflows/ci.yml/badge.svg)](https://github.com/krogk/cpp-project-template/actions/workflows/ci.yml)

## About
Light-weight C++ project template utilizing following technologies:
* [CMake](https://cmake.org/) - Build system
* [GTest](https://github.com/google/googletest) - Test Framework
* [.clang-format](https://clang.llvm.org/docs/ClangFormat.html) - Linter
* [Conan](https://conan.io/) - Package manager
* [Doxygen](https://www.doxygen.nl/) - Documentation
* [Docker](https://www.docker.com/) - Ubuntu jammy based container build environment
* [Github workflows](https://docs.github.com/en/actions/using-workflows/about-workflows) - Continuous Integration
* [CodeCov](https://about.codecov.io/) - Code Coverage reporting


### Github workflow CI 

The github workflow supports cross-platform build for following operating systems:
* Ubuntu - latest
* Macos - latest
* Windows - latest

Scripts to download following compilers across mentioned OS:
* GCC-11
* LLVM-14

## Dependencies

A dockerfile & build script has been provided for your convenience.
Please read the content of the /.devcontainer/dockerfile and build.sh first before executing.

### Minimum: 
* git
* Cmake
* Python3
* Conan

### Recommended:
Read the packages dev container downloads

1. Install docker & Setup sudo-less docker
2. Build docker image using container-manager.sh:
```
./container-manager.sh -b
```
3. Run docker image
```
./container-manager.sh -r
```

## Usage

### As a project template

There are several things you would want to change:
* CMake related: To fit your needs 
* Readme: Change link for badges
### Building
Invoke build script with -h to determine available build options:
```
./build.sh -h
```
### Testing
Invoke test script with -h to determine available test options:
```
./test.sh -h
```