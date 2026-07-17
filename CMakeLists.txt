cmake_minimum_required(VERSION 4.0)

find_package(cmake-bare REQUIRED PATHS node_modules/cmake-bare)
find_package(cmake-ports REQUIRED PATHS node_modules/cmake-ports)

project(bare_vips C CXX)

find_port(vips)

add_bare_module(bare_vips)

target_sources(
  ${bare_vips}
  PRIVATE
    binding.c
)

target_link_libraries(
  ${bare_vips}
  PUBLIC
    vips
)
