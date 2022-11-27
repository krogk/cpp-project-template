#!/usr/bin/env bash

# Exit if command fails
set -e 
# Return status of a pipeline.
# In case of a failure the value of the last (rightmost) command to exit with a non-zero status.
set -o pipefail
#set -o errexit -o pipefail -o noclobber -o nounset

# Set script directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Defaults Params, as script global variables
BUILD_TYPE="Debug"
VERBOSE="0"
JOBS="1"
TEST_PARAM=""

HelpPromptPrint () {
cat << EOF
----------------------------------------
####### Build Script Help Prompt #######
----------------------------------------
-h   | --help    : Display this prompt
------------BUILD-PARAMETERS------------
-d   | --debug   : Build type = debug
-r   | --relase  : Build type = release
------------------MISC------------------
-j # | --jobs #  : Enables parallel build with # jobs
-v   | --verbose : Enables verbose output
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
      BUILD_TYPE = "Debug"
      shift # argument
      ;;
    -r|--release)
      BUILD_TYPE = "Release"
      shift # argument
      ;;
    -v|--verbose)
      VERBOSE = "1"
      shift # argument
      ;;
    -t|--test_param)
      TEST_PARAM="$2"
      echo "The test parameter is = $TEST_PARAM"
      shift 2 # past argument & value
      ;;  
    -*|--*)
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
    rm -rf ${SCRIPT_DIR}/build/
fi

# Create build folder and change to it
mkdir build && cd build

### Conan
# Change the default profile to use libstdc++11
# https://docs.conan.io/en/latest/howtos/manage_gcc_abi.html#manage-gcc-abi
# https://stackoverflow.com/questions/61019721/why-cant-i-link-to-spdlog-library-installed-with-conan
conan profile update settings.compiler.libcxx=libstdc++11 default # Consider using helpers to set this automatically
# Install 
conan install ..
### CMake
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE}  ..  
cmake --build .
