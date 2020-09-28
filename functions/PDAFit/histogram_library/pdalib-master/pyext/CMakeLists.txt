cmake_policy(SET CMP0078 NEW)
cmake_policy(SET CMP0086 NEW)


FIND_PACKAGE(Python COMPONENTS Interpreter Development)
FIND_PACKAGE(PythonLibs)
INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_DIR})
LINK_LIBRARIES(${Python_LIBRARIES})

execute_process(
        COMMAND python -c
        "from __future__ import print_function\ntry: import numpy; print(numpy.get_include(), end='')\nexcept:pass\n"
        RESULT_VARIABLE PYTHON_PREFIX_RESULT
        OUTPUT_VARIABLE Python_NumPy_PATH
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
INCLUDE_DIRECTORIES(${Python_NumPy_PATH})


SET(MODULE_NAME chinet)

FIND_PACKAGE(SWIG REQUIRED)
INCLUDE(${SWIG_USE_FILE})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})

SET(CMAKE_SWIG_FLAGS "")
SET(SWIG_SRC chinet.i)

# The output path is controlled by the setup.py
#SET(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/pyext)

#[[
FILE(GLOB SRC_files "../src/*.cpp")
]]#

FILE(GLOB SRC_files
        "../src/Pda.cpp"
        )

SET_PROPERTY(
        SOURCE
        chinet.i
        PROPERTY
        CPLUSPLUS ON
)

SWIG_ADD_LIBRARY(
        ${MODULE_NAME}
        LANGUAGE python
        SOURCES
        chinet.i
        ${SRC_files}
)

TARGET_LINK_LIBRARIES(
        ${MODULE_NAME} PRIVATE
        ${HDF5_LIBRARIES}
        ${PYTHON_LIBRARY}
        ${BSON_LIBRARIES}
)

TARGET_COMPILE_DEFINITIONS(
        ${MODULE_NAME} PRIVATE
        ${BSON_DEFINITIONS}
)

