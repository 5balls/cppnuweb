% Copyright 2022 Florian Pesth
%
% This file is part of cppnuweb.
%
% cppnuweb is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as
% published by the Free Software Foundation version 3 of the
% License.
%
% cppnuweb is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

\section{cmake}
\codecmake
@d Standard definitions for CMakeLists.txt
@{
cmake_minimum_required(VERSION 3.7.0)
include(CMakePrintHelpers)
find_package(BISON 3.7.5)
find_program(REFLEX reflex)
if(REFLEX)
  message("-- Found REFLEX at " ${REFLEX})
  find_library(FLEX_LIBRARIES reflex HINTS $ENV{HOME}/lib REQUIRED)
  cmake_print_variables(FLEX_LIBRARIES)
  set(FLEX_INCLUDE_DIR $ENV{HOME}/include)
else()
  find_package(FLEX 2.6.4)
  set(FLEX_INCLUDE_DIR /usr/include)
  set(FLEX_LIBRARIES /usr/lib/x86_64-linux-gnu/libfl.a)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
message(STATUS "${CMAKE_CURRENT_SOURCE_DIR}")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


project(
  cppnuweb
  VERSION 0.1.0
  LANGUAGES CXX)
@}

It seems the flex package on debian is broken currently, so unfortunately the set commands at seem to be needed.

This bash scripts gather some information about the git repository and then we make them available to the program via preprocessor definitions:

@d Scripts for git in CMakeLists.txt
@{
@<Scripts for git in path @'@' in CMakeLists.txt@>
@}

@d Scripts for git in path @'path@' in CMakeLists.txt
@{
execute_process(
    COMMAND bash "-c" "git --git-dir ${CMAKE_CURRENT_LIST_DIR}@1/../.git --work-tree ${CMAKE_CURRENT_LIST_DIR}/.. describe --always --tags | tr -d '\n'"
    OUTPUT_VARIABLE GIT_VERSION
)


execute_process(
    COMMAND bash "-c" "if cleanstring=$(git --git-dir ${CMAKE_CURRENT_LIST_DIR}@1/../.git --work-tree ${CMAKE_CURRENT_LIST_DIR}/.. status --untracked-files=no --porcelain) && [ -z \"$cleanstring\" ]; then echo 'yes'; else echo 'no'; fi | tr -d '\n'"
    OUTPUT_VARIABLE GIT_CLEAN
)

execute_process(
    COMMAND bash "-c" "git log -1 --pretty=%B | tr -d '\n'"
    OUTPUT_VARIABLE GIT_LAST_COMMIT_MESSAGE
)

cmake_print_variables(GIT_VERSION)
cmake_print_variables(GIT_CLEAN)
cmake_print_variables(GIT_LAST_COMMIT_MESSAGE)

add_definitions(
    -DGIT_VERSION=${GIT_VERSION}
    -DGIT_CLEAN=${GIT_CLEAN}
    -DGIT_LAST_COMMIT_MESSAGE=${GIT_LAST_COMMIT_MESSAGE}
    -DCPPNUWEB_VERSION=${PROJECT_VERSION}
    -DCPPNUWEB_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
    -DCPPNUWEB_VERSION_MINOR=${PROJECT_VERSION_MINOR}
    -DCPPNUWEB_VERSION_PATCH=${PROJECT_VERSION_PATCH}
)
@}

@d Requirements for CMakeLists.txt
@{
@<Standard definitions for CMakeLists.txt@>
@<Scripts for git in CMakeLists.txt@>
@}

@O ../src/CMakeLists.txt
@{
@<Requirements for CMakeLists.txt@>

BISON_TARGET(MyParser nuweb.y ${CMAKE_CURRENT_BINARY_DIR}/../../src/parser.cpp
        DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/../../src/parser.h
        COMPILE_FLAGS "-v -Wcounterexamples")
if(REFLEX)
  set(FLEX_MyLexer_OUTPUTS ${CMAKE_CURRENT_BINARY_DIR}/../../src/lexer.cpp)
  add_custom_command(OUTPUT ${FLEX_MyLexer_OUTPUTS}
    COMMAND reflex --bison-cc -o ${CMAKE_CURRENT_BINARY_DIR}/../../src/lexer.cpp ${CMAKE_CURRENT_BINARY_DIR}/../../src/nuweb.l --header-file=${CMAKE_CURRENT_BINARY_DIR}/../../src/lexer.h
    MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/../../src/nuweb.l
    COMMENT "[REFLEX] Building lexer..."
  )
else()
  FLEX_TARGET(MyLexer nuweb.l ${CMAKE_CURRENT_BINARY_DIR}/../../src/lexer.cpp)
  ADD_FLEX_BISON_DEPENDENCY(MyLexer MyParser)
endif()

cmake_print_variables(BISON_MyParser_OUTPUTS)
cmake_print_variables(FLEX_MyLexer_OUTPUTS)

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${FLEX_INCLUDE_DIR})
add_executable(nuweb
@<C++ files@>
${BISON_MyParser_OUTPUTS}
${FLEX_MyLexer_OUTPUTS}
)
if(REFLEX)
target_compile_definitions(nuweb PUBLIC REFLEX)
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -ggdb")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -ggdb")

target_link_libraries(nuweb PUBLIC ${LIBS} ${FLEX_LIBRARIES})

# Currently only local install target for nuweb
install(TARGETS nuweb DESTINATION $ENV{HOME}/bin)
@}

