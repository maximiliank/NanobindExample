foreach(file conan_provider)
    set(DESTINATION_FILE ${CMAKE_BINARY_DIR}/${file}.cmake)
    if(NOT EXISTS "${DESTINATION_FILE}")
        message(STATUS "Downloading ${file}.cmake from https://raw.githubusercontent.com/conan-io/cmake-conan/develop2")
        file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/develop2/${file}.cmake"
                "${DESTINATION_FILE}"
                STATUS DOWNLOAD_STATUS
                TLS_VERIFY ON)
        # Separate the returned status code, and error message.
        list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
        list(GET DOWNLOAD_STATUS 1 ERROR_MESSAGE)
        # Check if download was successful.
        if(${STATUS_CODE} EQUAL 0)
            message(STATUS "Download completed successfully ${DESTINATION_FILE}")
        else()
            # Exit CMake if the download failed, printing the error message.
            file(REMOVE "${DESTINATION_FILE}")
            message(FATAL_ERROR "Error occurred during download of ${file}.cmake: ${ERROR_MESSAGE}")
        endif()
    endif()
endforeach()

set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES ${CMAKE_BINARY_DIR}/conan_provider.cmake)
