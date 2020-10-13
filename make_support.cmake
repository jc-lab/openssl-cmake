if (MSVC)
    find_program(MAKE_PROGRAM "nmake")
else()
    find_program(MAKE_PROGRAM "make")
endif()

message("MAKE_PROGRAM = ${MAKE_PROGRAM}")

if (NOT MAKE_PROGRAM)
    message(FATAL_ERROR "make program not found: ${MAKE_PROGRAM}")
endif ()
message(STATUS "Found make: ${MAKE_PROGRAM}")
