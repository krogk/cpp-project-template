# Find clang-format program
find_program(CLANG_FORMAT "clang-format")

# If clang format is found
if(CLANG_FORMAT)
    message([STATUS] " .clang-format program has been found, adding formatting target..." ...)
    # Find all h/c/hpp/cpp files in src/
    file(GLOB_RECURSE ALL_CXX_SOURCE_FILES
        ${PROJECT_SOURCE_DIR}/src/*.c
        ${PROJECT_SOURCE_DIR}/src/*.cpp 
        ${PROJECT_SOURCE_DIR}/src/*.h
        ${PROJECT_SOURCE_DIR}/src/*.hpp
    )
    # Add header/source files target and format
    add_custom_target(
        clangformat
        COMMAND clang-format
        -i # In place mode 
        -style=file # Use file
        ${ALL_CXX_SOURCE_FILES}
    )
else(CLANG_FORMAT)
    message([WARNING] " .clang-format program has not been found, skipping formatting target..." ...)
endif(CLANG_FORMAT)
