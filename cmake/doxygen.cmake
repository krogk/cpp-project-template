# Find package
find_package(Doxygen)

if(DOXYGEN_FOUND)
    message([STATUS] " Doxygen found, adding doxygen target...")
    # Set input doxyfile
    set(DOXYGEN_IN ${PROJECT_SOURCE_DIR}/docs/Doxyfile.in)
    # Set output doxyfile
    set(DOXYGEN_OUT ${PROJECT_SOURCE_DIR}/docs/doxygen/Doxyfile.out)
    # Set docs output file
    set(DOXYGEN_OUTPUT_DIR ${PROJECT_SOURCE_DIR}/docs/doxygen)
    # Just copy the doxyfile over for now TODO: configure with cmake variables
    configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
    # Add target
    add_custom_target(doxygen ALL
        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
        WORKING_DIRECTORY ${DOXYGEN_OUTPUT_DIR}
        COMMENT "Generating documentation with Doxygen"
        VERBATIM
    )
else(DOXYGEN_FOUND)
    message([WARNING] " Doxygen not found skipping doc generation...")
endif(DOXYGEN_FOUND)