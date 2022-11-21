find_package(spdlog)

add_executable(spdlogtest spdlog-test.cpp)
target_link_libraries(spdlogtest ${CONAN_LIBS})