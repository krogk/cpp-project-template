# Find clang-format program
find_program(CPP_CHECK_FOUND NAMES cppcheck)
# If it is
if(CPPCHECK_FOUND)
    message([STATUS] " cppcheck found adding cppcheck target...")
    # Find all h/c/hpp/cpp files in src/
    file(GLOB_RECURSE ALL_CXX_SOURCE_FILES
        ${PROJECT_SOURCE_DIR}/src/*.c
        ${PROJECT_SOURCE_DIR}/src/*.cpp 
        ${PROJECT_SOURCE_DIR}/src/*.h
        ${PROJECT_SOURCE_DIR}/src/*.hpp
    )
    # Add target for cpp check
    add_custom_target(
        cppcheck
        COMMAND /usr/bin/cppcheck
        --enable=warning,performance,portability,information,missingInclude
        --std=c++20 --language=c++
        --library=qt.cfg
        --template="[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)"
        --verbose
        --quiet
        ${ALL_CXX_SOURCE_FILES}
    )
else(CPPCHECK_FOUND)
    message([WARNING] " cppcheck not found skipping static analysis...")
endif(CPPCHECK_FOUND)