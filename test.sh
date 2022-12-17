#!/usr/bin/env bash

# Exit if command fails
# Return status of a pipeline.
# In case of a failure the value of the last (rightmost) command to exit with a non-zero status.
set -euo pipefail

#### GLOBAL VARIABLES #####

# Set script directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BUILD_DIR="${SCRIPT_DIR}/build"
COVERAGE_DIR="${BUILD_DIR}/coverage"
COVERAGE="OFF"
TARGETS=()
TEST_PATHS=()

#### FUNCTION DEFINITIONS #####

###
# Brief: Print help prompt and exit
#
# 
#
###
HelpPromptPrint () {
cat << EOF
----------------------------------------
####### Test Script Help Prompt #######
----------------------------------------
-h | --help : Display this prompt
-a | --all  : Runs whole test suite
-c | --cov  : Generates code coverage
---------------UNIT-TESTS---------------
-u | --unit : Run all unit tests
-----------INTEGRATION-TESTS------------
-i | --int  : Run all integration tests
--------------SYSTEM-TESTS--------------
-s | --sys  : Run all system tests
---------------END-TO-END---------------
-e | --end  : Run all end to end tests
-------------------MIX------------------
-m  targets | --mix targets  : run specified tests, where targets are exact test bin names 
----------------------------------------
########################################
----------------------------------------
EOF
}

###
# Brief: Code Coverage pre processing
#
# 
#
###
CodeCoveragePreProc() {
    # Check if coverage enabled
    if [[ ${COVERAGE} == "ON" ]]; then
        echo "Executing code coverage pre processing..."
        # Check if coverage dir exists
        if [[ -d "$COVERAGE_DIR" ]]; then
            echo "Coverage folder already exists, clearing contents..."
            rm -rf ${COVERAGE_DIR}/
            mkdir ${COVERAGE_DIR}/
        else
            echo "Creating folder for code coverage results..."
            mkdir ${COVERAGE_DIR}/
        fi

        # For coverage to be generated the source files
        # must be complied using following flags: 
        # -g -pg --coverage 

        # Generate the baseline coverage data file i.e. initial zero coverage report
        # use this to compare with test case coverage report to get accurate
        # percentage even when not all source code files were loaded during the test/s.
        # Using '--no-external' to remove coverage for external source files
        # i.e. those not provided by '--directory' option.
        lcov --capture --initial --directory ${BUILD_DIR} \
          --output-file ${COVERAGE_DIR}/out_lcov_base.info
    else
        echo "Skipping code coverage pre processing..."
    fi
}

###
# Brief: Code Coverage post processing
#
# 
#
###
CodeCoveragePostProc() {
    # Check if coverage enabled
    if [[ ${COVERAGE} == "ON" ]]; then
        echo "Executing code coverage post processing..."

        # Check if coverage dir exists
        #if [[ -d COVERAGE_DIR ]]; then
        #    echo "Coverage folder does not exist..."
        #    echo "Aborting test run..."
        #    exit 1
        #fi

        # Note: For coverage to be generated the source files
        # must be complied using following flags: 
        # -g -pg --coverage 

        # Generate lcov data (tracefiles) for the test case
        lcov --capture --directory ${BUILD_DIR} --output-file ${COVERAGE_DIR}/out_lcov_test.info

        # combine lcov before and after tracefiles i.e., base & test lcov files
        lcov --add-tracefile ${COVERAGE_DIR}/out_lcov_base.info \
            --add-tracefile ${COVERAGE_DIR}/out_lcov_test.info \
            --output-file ${COVERAGE_DIR}/out_lcov_total.info

        # convert lcov report to html files
        genhtml ${COVERAGE_DIR}/out_lcov_total.info \
            --output-directory ${COVERAGE_DIR}/out_lcov_html \
            --demangle-cpp --legend --title "Cpp basic gcov test"
    else
        echo "Skipping code coverage post processing..."
    fi
}

###
# Brief: Parse test binray names
# from input arguments
# 
#
###
ParseTestTargets() {
    echo "Parsing test targets..."
    while [[ $# -gt 0 ]]; do
        #echo "target: '"$1"' "
        case $1 in
            -*)
              echo "Use script argument ${1} before -m/--mix targets"
              # TODO: Detect & return when argument is meet,
              shift
              ;;
            *)
              # Add target
              TARGETS+=("$1") 
              echo "Added '"$1"' to test target list... "
              shift # past argument
              ;;
        esac
    done
    echo "Parsing done..."
}

###
# Brief: Steps through directories reursivley 
# to obtain filepaths cotnaining specified
# keywords
#
###
FindTestsPaths() {
    #echo "Finding test executables in $1..."
    shopt -s nullglob dotglob
    # For the pathname 
    for pathname in "$1"/*; do
        # If pathname is directory
        if [ -d "$pathname" ]; then
            # recursive call
            FindTestsPaths "$pathname"
        # Otherwise it is a file
        else
            #echo "path: $pathname "
            # For each target string
            for target in "${TARGETS[@]}"; do
                #echo "target: $target "
                # Check if [keyword is present withn the pathname] and [is executable] and (is not)[already on the list]
                if [[ "$pathname" == *"$target"* ]] && [[ -x "$pathname" ]] && !( printf '%s\0' "${TEST_PATHS[@]}" | grep -Fxqz -- "${pathname}" ) ; then
                    # Meets criteria add to list
                    TEST_PATHS+=("${pathname}")
                    echo "Test executable added to the list: '$pathname'"
                fi
            done
        fi
    done
}

###
# Brief:
#
# [in] from global variable containing
#
###
ExecuteTests() {
    # Get tests needed for execution
    FindTestsPaths ${BUILD_DIR}
    # TODO: Check if all targets have been found and report if not

    # Run code coverage pre processing
    CodeCoveragePreProc

    # Execute tests
    # Note: If code cove is enabled, executing test binaries generates
    # '.gcda' (gcov data) files corresponding to '.gcno' files complied
    # For each entry in the list
    for test in "${TEST_PATHS[@]}"; do
        # Get folder name
        test_dir="$(dirname "${test}")"
        # Get executable name
        test_exe="$(basename "${test}")"
        cd ${test_dir}
        # Execute test
        ./${test_exe}
    done

    # Run code coverage post processing
    CodeCoveragePostProc
}

#### MAIN ENTRY #####

# Check if build dir exists & exit if it doesn't
if [[ -d ${BUILD_DIR} ]]; then
     echo "Build folder (${BUILD_DIR}) found..."
else
    echo "Error: Build folder (${BUILD_DIR}) could not have been found..."
    echo "Aborting test run..."
    exit 1
fi

echo "Parsing script input arguments..."
# Until no arguments left to process:
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
          HelpPromptPrint
          exit 0
          ;;
        -c|--coverage)
          COVERAGE="ON"
          shift # argument
          ;;
        -a|--all)
          TARGETS=("ut_" "integ_" "sys_" "end_")
          shift # argument
          ;;
        -u|--unit)
          TARGETS+=("ut_")
          shift # argument
          ;;
        -i|--integ)
          TARGETS+=("integ_")
          shift
          ;;
        -s|--sys)
          TARGETS+=("sys_")
          shift # argument
          ;;
        -e|--end)
          TARGETS+=("end_")
          shift # argument
          ;;
        -m|--mix)
          shift # -m argument
          # parse targets
          ParseTestTargets "$@" 
          break #TODO: Debug, when break is removed the program goes into infnite loop preventing parsing of other arguments
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

# Execute tests
ExecuteTests