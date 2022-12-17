#!/usr/bin/env bash

# Exit if command fails
# Return status of a pipeline.
# In case of a failure the value of the last (rightmost) command to exit with a non-zero status.
set -euo pipefail
#set -o errexit -o pipefail -o noclobber -o nounset

# Set script directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BUILD_DIR="${SCRIPT_DIR}/build"

# Defaults Params, as script global variables
BUILD_TYPE="Debug"
VERBOSE=""
JOBS="1"
TEST_PARAM=""
COVERAGE="OFF"
CC=""
CXX=""
COMPILER="gcc"
COMPILER_VERSION="11"

HelpPromptPrint () {
cat << EOF
----------------------------------------
####### Build Script Help Prompt #######
----------------------------------------
-h   | --help      : Display this prompt
---------------BUILD-TYPE---------------
-d   | --debug     : Build type = debug (default)
-r   | --relase    : Build type = release
----------------COMPILER----------------
-compiler compiler-version | --compiler compiler-version : (gcc-11 by default)
------------------MISC------------------
-j # | --jobs #    : Enables parallel build with # jobs (1 by default)
-v   | --verbose   : Enables verbose output (off by default)
-c   | --coverage  : Enable code coverage
----------------------------------------
########################################
----------------------------------------
EOF
}

# Parse script arguments
POSITIONAL_ARGS=()
# Until no arguments left to process:
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      HelpPromptPrint
      exit 0
      ;;
    -d|--debug)
      BUILD_TYPE="Debug"
      shift # argument
      ;;
    -r|--release)
      BUILD_TYPE="Release"
      shift # argument
      ;;
    -v|--verbose)
      VERBOSE="-v"
      shift # argument
      ;;
    -j|--jobs)
      JOBS="$2"
      shift 2 # past argument & value
      ;;
    -compiler|--compiler)
      COMPILER_INPUT=$2
      # Remove  - from the command by removing last pattern
      COMPILER="${COMPILER_INPUT%%-*}"
      # Remove compiler name by removing the first pattern
      COMPILER_VERSION="${COMPILER_INPUT##*-}"
      shift 2
      ;;
    -cxx)
      CXX="-DCMAKE_CXX_COMPILER=$2"
      shift 2 # past argument & value
      ;;
    -cc)
      CC="-DCMAKE_C_COMPILER=$2"
      shift 2 # past argument & value
      ;;
    -c|--coverage)
      COVERAGE="ON"
      shift # past argument
      ;;  
    -*)
      echo "Unknown script argument $1" 
      exit 1
      ;;
    *)
      # save positional arg
      POSITIONAL_ARGS+=("$1") 
      shift # past argument
      ;;
  esac
done

# Check if build dir exists & delete it
if [[ -d ${SCRIPT_DIR}/build/ ]]
then
    rm -rf "${SCRIPT_DIR}"/build/
fi

# Create build folder and change to it
mkdir build && cd build

### Conan
# Create new default profile
#conan profile new default --detect
# Change the default profile to use libstdc++11
# https://docs.conan.io/en/latest/howtos/manage_gcc_abi.html#manage-gcc-abi
# https://stackoverflow.com/questions/61019721/why-cant-i-link-to-spdlog-library-installed-with-conan
#TODO: automate for OS+Compiler combinations
#conan profile update settings.compiler.libcxx=libstdc++11 default
#conan profile update settings.compiler.compiler=libstdc++11 default
#conan profile update settings.compiler.compiler.version=libstdc++11 default
#conan profile update settings.compiler.compiler.build_type=libstdc++11 default
#Show default conan profile
#conan profile show default
# Install 
conan install .. -s build_type=${BUILD_TYPE} --install-folder=${BUILD_DIR} --build missing -s compiler=${COMPILER} -s compiler.version=${COMPILER_VERSION} -s compiler.libcxx=libstdc++11
### CMake
cmake ${CC} ${CXX} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DENABLE_COVERAGE=${COVERAGE} ..  
cmake --build . -j ${JOBS} ${VERBOSE} 
