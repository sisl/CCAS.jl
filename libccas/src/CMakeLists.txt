cmake_minimum_required(VERSION 2.8)

project(libccas)
set(CMAKE_BUILD_TYPE Release)

set(Boost_DEBUG    ON)

find_package(Boost 1.46.0)
include_directories(${Boost_INCLUDE_DIRS})

include(GenerateExportHeader)

add_library(libccas SHARED libccas.cpp)
set_target_properties(libccas PROPERTIES PREFIX "")
generate_export_header(libccas 
		BASE_NAME libccas
		EXPORT_MACRO_NAME libccas_EXPORT
		EXPORT_FILE_NAME ${CMAKE_SOURCE_DIR}/libccas_Export.h
		STATIC_DEFINE libccas_BUILT_AS_STATIC)

if(NOT MSVC)
  add_definitions(-Dlibccas_BUILT_AS_STATIC)
endif()


install(TARGETS libccas CONFIGURATIONS Debug Release
		RUNTIME DESTINATION ${CMAKE_SOURCE_DIR}/../lib
		LIBRARY DESTINATION ${CMAKE_SOURCE_DIR}/../lib
		ARCHIVE DESTINATION ${CMAKE_SOURCE_DIR}/../lib)
install(FILES libccas.h DESTINATION ${CMAKE_SOURCE_DIR}/../include)
install(FILES ${CMAKE_SOURCE_DIR}/libccas_Export.h DESTINATION ${CMAKE_SOURCE_DIR}/../include)
