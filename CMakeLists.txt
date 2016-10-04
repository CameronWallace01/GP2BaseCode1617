cmake_minimum_required (VERSION 2.8)
project (GP2BaseCode1617)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_CXX_FLAGS "-std=c++0x -g ${CMAKE_CXX_FLAGS}")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${project_SOURCE_DIR}/cmake")

if (NOT WIN32)
	set(CMAKE_DL_LIBS ${CMAKE_DL_LIBS} pthread)
endif(NOT WIN32)

set(CMAKE_PREFIX_PATH $ENV{GLEW_ROOT})
set(CMAKE_LIBRARY_PATH $ENV{GLEW_ROOT}/lib/Release/x64/)

find_package(SDL2 REQUIRED)
find_package(TinyXML REQUIRED)

add_subdirectory(GameApplication)
add_executable(GP2BaseCode1617 src/main.cpp src/MyGame.cpp include/MyGame.h)
include_directories(GP2BaseCode1617 GameApplication/include/ include/ ${SDL2_INCLUDE_DIR} ${TINYXML_INCLUDE_DIR} ${OPENGL_INCLUDE_DIRS} ${GLM_INCLUDE_DIRS} ${GLEW_INCLUDE_DIRS})

target_link_libraries (GP2BaseCode1617 GameApplication)

if (MSVC)
add_custom_command(TARGET GP2BaseCode1617  POST_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy_directory
                 ${CMAKE_SOURCE_DIR}/dlls $<TARGET_FILE_DIR:GP2BaseCode1617>)
endif (MSVC)

add_custom_command(TARGET GP2BaseCode1617  PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy_directory
                 ${CMAKE_SOURCE_DIR}/assets $<TARGET_FILE_DIR:GP2BaseCode1617>/assets)

# Gather list of all .xml and .conf files in "/config"
file(GLOB XMLFiles ${CMAKE_SOURCE_DIR}/*.xml)

foreach(XMLFile ${XMLFiles})
  add_custom_command(TARGET GP2BaseCode1617 PRE_BUILD
                     COMMAND ${CMAKE_COMMAND} -E
                         copy ${XMLFile} $<TARGET_FILE_DIR:GP2BaseCode1617>)
endforeach()
