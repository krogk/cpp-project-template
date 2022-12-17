#!/bin/bash

# Expected input arguments 1:os 2:compiler 3: compiler-version
# For example: ./compiler-setup.sh linux llvm 14

# Initialize global variables with script arguments
RUNNER_OS=$1
COMPILER_INPUT=$2

HelpPromptPrint () {
cat << EOF
----------------------------------------
##### C/C++ Compiler Setup Script #####
----------------------------------------
-h   | --help    : Display this prompt
-------------------OS-------------------
linux   : apt based install
macos   : brew based install
windows : choco based install
---------------Compilers----------------
gcc  | g++             : GCC
llvm | clang | clang++ : LLVM
-----------------USAGE------------------
./compiler-setup.sh linux llvm-14
----------------------------------------
########################################
----------------------------------------
EOF
}

# Until no arguments left to process:
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      HelpPromptPrint
      exit 0
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

function InstalCompiler {
    # Check if the version has been passed
    if [[ -n $3 ]]; then
        _VER=$3
        P_VER='-'$_VER
    fi

    # Parse the compiler & version
    case $2 in
        # GCC
        gcc | g++)
            _CC=gcc
            _CXX=g++
            PKGS="${_CC}${P_VER} ${_CXX}${P_VER}"
            WIN_PKGS="mingw --version=${_VER}"
            MAC_PKGS="gcc@${_VER}"
        ;;
        # Clang
        llvm | clang | clang++)
            _CC=clang
            _CXX=clang++
            PKGS="${_CC}${P_VER}"
            WIN_PKGS="llvm --version=$_VER"
            MAC_PKGS="llvm@$_VER"
        ;;
        *)
            echo "::error ::Compiler setup for: '$2' not supported"
            exit 1
        ;;
    esac

    # Parse OS
        case $1 in
        Linux)
            echo "::group::apt install"
            echo "apt install"
            echo sudo apt-get update
            $ECHO sudo apt-get update
            echo apt-get install ${PKGS} -y
            $ECHO sudo apt-get install ${PKGS} -y
            echo "::endgroup::"
            echo "cc=${_CC}${P_VER}" >> ${GITHUB_OUTPUT}
            echo "cxx=${_CXX}${P_VER}" >> ${GITHUB_OUTPUT}
        ;;
        Windows)
            echo "::group::choco install"
            echo "choco install"
            echo choco upgrade ${WIN_PKGS} -y --no-progress --allow-downgrade
            $ECHO choco upgrade ${WIN_PKGS} -y --no-progress --allow-downgrade
            echo "::endgroup::"
            echo "cc=${_CC}" >> ${GITHUB_OUTPUT}
            echo "cxx=${_CXX}" >> ${GITHUB_OUTPUT}
        ;;
        macOS)
            case ${_CC}${P_VER} in
                gcc-*)
                    echo "::group::Brew install"
                    echo brew update
                    $ECHO brew update
                    echo brew install ${MAC_PKGS}
                    $ECHO brew install ${MAC_PKGS}
                    echo brew link ${MAC_PKGS}
                    $ECHO brew link ${MAC_PKGS}
                    echo "::endgroup::"
                    echo "cc=/usr/local/bin/${_CC}${P_VER}" >> ${GITHUB_OUTPUT}
                    echo "cxx=/usr/local/bin/${_CXX}${P_VER}" >> ${GITHUB_OUTPUT}
                ;;
                gcc)
                    echo "::warning ::MacOS - GCC version must be specified, falling back to clang"
                    echo "cc=clang" >> ${GITHUB_OUTPUT}
                    echo "cxx=clang++" >> ${GITHUB_OUTPUT}
                ;;
                clang*)
                    echo "::notice ::MacOS - Compilers fallback to default system clang"
                    echo "cc=clang" >> ${GITHUB_OUTPUT}
                    echo "cxx=clang++" >> ${GITHUB_OUTPUT}
                ;;
            esac
        ;;
        *)
            echo "::error ::OS: '$1' not supported"
            exit 1
        ;;
    esac
}

# Remove  - from the command by removing last pattern
COMPILER="${COMPILER_INPUT%%-*}"
# Remove compiler name by removing the first pattern
VERSION="${COMPILER_INPUT##*-}"
#
echo "Target OS: ${RUNNER_OS}"
echo "Compiler: ${COMPILER}"
echo "Compiler version: ${VERSION}"
# Invoke 
InstalCompiler "$RUNNER_OS" "$COMPILER" "$VERSION"  #RUNNER_OS COMPILER VERSION