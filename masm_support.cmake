if (MSVC)
    if (X64)
        # In case of NMake Makefiles CMAKE_ASM_COMPILER will find cl.exe, thus we need
        # to do it manually for both ml.exe and ml64.exe
        find_program(CMAKE_ASM_COMPILER ml64.exe HINTS "${cl_path}" DOC "path to assembler")
        if ("${CMAKE_GENERATOR}" MATCHES "NMake Makefiles")
            set(CMAKE_ASM_COMPILER "ml64.exe")
        endif()
    else (X64)
        find_program(CMAKE_ASM_COMPILER ml.exe HINTS "${cl_path}" DOC "path to assembler")
        if ("${CMAKE_GENERATOR}" MATCHES "NMake Makefiles")
            set(CMAKE_ASM_COMPILER "ml.exe")
        endif()
    endif (X64)
    if (NOT CMAKE_ASM_COMPILER)
        message(FATAL_ERROR "assembler not found: required to build")
    endif (NOT CMAKE_ASM_COMPILER)
    message(STATUS "Found assembler: ${CMAKE_ASM_COMPILER}")
    if (NOT DEFINED GENERATE_PDBS OR GENERATE_PDBS)
        set(ASM_DBG "/Zi /Zd")
    else ()
        set(ASM_DBG "")
    endif ()
endif()
