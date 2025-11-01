cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project({{PROJECT_NAME}})

# Source files
target_sources(app PRIVATE
    src/main.c
)

# Uncomment to add include directories
# target_include_directories(app PRIVATE include)

# Uncomment to link with common library
# target_link_libraries(app PRIVATE zephyr_common)
