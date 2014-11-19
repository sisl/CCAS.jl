cmake_minimum_required(VERSION 2.8)

project(libccas)

set(Boost_DEBUG    ON)

find_package(Boost 1.57.0)
include_directories(${Boost_INCLUDE_DIRS})

include(GenerateExportHeader)
add_library(libccas SHARED libccas.cpp)
generate_export_header(libccas EXPORT_FILE_NAME ${CMAKE_BINARY_DIR}/libccas_export.h 
		BASE_NAME libccas
		EXPORT_MACRO_NAME libccas_EXPORT
		EXPORT_FILE_NAME libccas_Export.h
		STATIC_DEFINE libccas_BUILT_AS_STATIC)

install(TARGETS libccas DESTINATION lib)
install(FILES libccas.h DESTINATION include)