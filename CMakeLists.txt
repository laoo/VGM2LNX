cmake_minimum_required (VERSION 3.8)

project ("VGM2LNX")

set(CMAKE_CXX_STANDARD 17)

if ( STANDALONE )
  set( CMAKE_CXX_FLAGS "-DSTANDALONE")
  add_executable (vgm2lnx VGM2LNX.cpp convert.cpp )
else()
   add_executable (vgm2v2l VGM2LNX.cpp convert.cpp )
endif()
