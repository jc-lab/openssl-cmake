include(masm_support.cmake)

# example
# set(OPENSSL_FETCH_INFO
#         URL https://www.openssl.org/source/openssl-1.1.1h.tar.gz
#         URL_HASH SHA256=5c9ca8774bd7b03e5784f26ae9e9e6d749c9da2438545077e6b3d755a06595d9
#         )

FetchContent_Declare(
        openssl_src
        ${OPENSSL_FETCH_INFO}
)
FetchContent_GetProperties(openssl_src)
if (NOT openssl_src_POPULATED)
    FetchContent_Populate(openssl_src)
endif()

if(WIN32)
    set(OPENSSL_MAKEFILE "${openssl_src_SOURCE_DIR}/makefile")
    FILE(COPY ${CMAKE_CURRENT_SOURCE_DIR}/10-main.conf DESTINATION ${openssl_src_SOURCE_DIR}/Configurations)
    if (X64)
        set(OPENSSL_COMPILER "VC-WIN64A")
    else()
        set(OPENSSL_COMPILER "VC-WIN32")
    endif()
else()
    set(OPENSSL_MAKEFILE "${openssl_src_SOURCE_DIR}/Makefile")
    if (X64)
        set(OPENSSL_COMPILER "linux-x86_64")
    else()
        set(OPENSSL_COMPILER "linux-x86")
    endif()
endif()

set(OPENSSL_CONFIGURE_OPTIONS no-zlib no-md2 no-mdc2 no-rc4 no-rc5 no-asm shared)
set(OPENSSL_MAKE_OPTIONS)

message("openssl configure: perl Configure ${OPENSSL_COMPILER} ${OPENSSL_CONFIGURE_OPTIONS}")
add_custom_command(
        OUTPUT "${OPENSSL_MAKEFILE}"
        COMMAND perl Configure ${OPENSSL_COMPILER} ${OPENSSL_CONFIGURE_OPTIONS}
        WORKING_DIRECTORY ${openssl_src_SOURCE_DIR}
)

add_custom_target(openssl-config DEPENDS "${OPENSSL_MAKEFILE}")

add_custom_target(openssl-build
        COMMAND ${CMAKE_MAKE_PROGRAM} ${OPENSSL_MAKE_OPTIONS}
        WORKING_DIRECTORY ${openssl_src_SOURCE_DIR}
        DEPENDS openssl-config
)

add_library(openssl_ssl SHARED IMPORTED GLOBAL)
add_library(openssl_ssl_static STATIC IMPORTED GLOBAL)
add_library(openssl_crypto SHARED IMPORTED GLOBAL)
add_library(openssl_crypto_static STATIC IMPORTED GLOBAL)

add_dependencies(openssl_ssl openssl-build)
add_dependencies(openssl_ssl_static openssl-build)
add_dependencies(openssl_crypto openssl-build)
add_dependencies(openssl_crypto_static openssl-build)

target_include_directories(openssl_ssl
        INTERFACE
        ${openssl_src_SOURCE_DIR}/include
        )
target_include_directories(openssl_ssl_static
        INTERFACE
        ${openssl_src_SOURCE_DIR}/include
        )
target_include_directories(openssl_crypto
        INTERFACE
        ${openssl_src_SOURCE_DIR}/include
        )
target_include_directories(openssl_crypto_static
        INTERFACE
        ${openssl_src_SOURCE_DIR}/include
        )

if(MSVC)
    add_compile_definitions(openssl_ssl
            INTERFACE
            OPENSSL_OPT_WINDLL)
    add_compile_definitions(openssl_crypto
            INTERFACE
            OPENSSL_OPT_WINDLL)
    set_target_properties(
            openssl_crypto PROPERTIES
            IMPORTED_LOCATION ${openssl_src_SOURCE_DIR}/libcrypto-1_1.dll
            IMPORTED_IMPLIB ${openssl_src_SOURCE_DIR}/libcrypto.lib
            INTERFACE_INCLUDE_DIRECTORIES ${openssl_src_SOURCE_DIR}/include
    )
    set_target_properties(
            openssl_crypto_static PROPERTIES
            IMPORTED_LOCATION ${openssl_src_SOURCE_DIR}/libcrypto_static.lib
            INTERFACE_INCLUDE_DIRECTORIES ${openssl_src_SOURCE_DIR}/include
    )
    set_target_properties(
            openssl_ssl PROPERTIES
            IMPORTED_LOCATION ${openssl_src_SOURCE_DIR}/libssl-1_1.dll
            IMPORTED_IMPLIB ${openssl_src_SOURCE_DIR}/libssl.lib
            INTERFACE_INCLUDE_DIRECTORIES ${openssl_src_SOURCE_DIR}/include
    )
    set_target_properties(
            openssl_ssl_static PROPERTIES
            IMPORTED_LOCATION ${openssl_src_SOURCE_DIR}/libssl_static.lib
            INTERFACE_INCLUDE_DIRECTORIES ${openssl_src_SOURCE_DIR}/include
    )

    install(FILES
            ${openssl_src_SOURCE_DIR}/libcrypto-1_1.dll
            ${openssl_src_SOURCE_DIR}/libssl-1_1.dll
            ${openssl_src_SOURCE_DIR}/apps/openssl.exe
            DESTINATION bin
            )

    install(FILES
            ${openssl_src_SOURCE_DIR}/libcrypto.lib
            ${openssl_src_SOURCE_DIR}/libssl.lib
            ${openssl_src_SOURCE_DIR}/libcrypto_static.lib
            ${openssl_src_SOURCE_DIR}/libssl_static.lib
            DESTINATION lib
            )

    install(FILES ${openssl_src_SOURCE_DIR}/libcrypto-1_1.pdb
            FILES ${openssl_src_SOURCE_DIR}/libssl-1_1.pdb
            FILES ${openssl_src_SOURCE_DIR}/ossl_static.pdb
            DESTINATION dbg
            )
else()
    set_target_properties(
            openssl_crypto PROPERTIES
            IMPORTED_LOCATION ${openssl_src_SOURCE_DIR}/libcrypto.so
            INTERFACE_INCLUDE_DIRECTORIES ${openssl_src_SOURCE_DIR}/include
    )
    set_target_properties(
            openssl_crypto_static PROPERTIES
            IMPORTED_LOCATION ${openssl_src_SOURCE_DIR}/libcrypto.a
            INTERFACE_INCLUDE_DIRECTORIES ${openssl_src_SOURCE_DIR}/include
    )
    set_target_properties(
            openssl_ssl PROPERTIES
            IMPORTED_LOCATION ${openssl_src_SOURCE_DIR}/libssl.so
            INTERFACE_INCLUDE_DIRECTORIES ${openssl_src_SOURCE_DIR}/include
    )
    set_target_properties(
            openssl_ssl_static PROPERTIES
            IMPORTED_LOCATION ${openssl_src_SOURCE_DIR}/libssl.a
            INTERFACE_INCLUDE_DIRECTORIES ${openssl_src_SOURCE_DIR}/include
    )

    install(FILES
            ${openssl_src_SOURCE_DIR}/libcrypto.so
            ${openssl_src_SOURCE_DIR}/libcrypto.so.1.1
            ${openssl_src_SOURCE_DIR}/libssl.so
            ${openssl_src_SOURCE_DIR}/libssl.so.1.1
            ${openssl_src_SOURCE_DIR}/apps/openssl
            DESTINATION bin
            )

    install(FILES
            ${openssl_src_SOURCE_DIR}/libcrypto.a
            ${openssl_src_SOURCE_DIR}/libssl.a
            DESTINATION lib
            )
endif()

install(DIRECTORY ${openssl_src_SOURCE_DIR}/include/openssl/
        DESTINATION include/openssl
        )

if(OPENSSL_USE_STATIC_LIBS)
    add_library(OpenSSL::Crypto ALIAS openssl_crypto)
    add_library(OpenSSL::SSL ALIAS openssl_ssl)
else()
    add_library(OpenSSL::Crypto ALIAS openssl_crypto_static)
    add_library(OpenSSL::SSL ALIAS openssl_ssl_static)
endif()
