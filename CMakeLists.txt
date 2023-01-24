cmake_minimum_required (VERSION 3.2)

# give the project a name and specify which languages to use
# if you don't specify the languages here it will default to C and C++
project(fortran2python LANGUAGES Fortran)

enable_language(Fortran)
enable_testing()

#
# Find NetCDF
#

# allow the user to set the variables manually
set(NETCDF_INCLUDE_DIRS "" CACHE PATH "Directories containing the netCDF C include files and Fortran module files")
set(NETCDF_LIBRARIES "" CACHE STRING "List of netCDF libraries")

# Setting NETCDF_INCLUDE_DIRS and NETCDF_LIBRARIES takes precedence.
# If not set then key off from nc-config and optionally nf-config
if (NETCDF_INCLUDE_DIRS STREQUAL "" OR NETCDF_LIBRARIES STREQUAL "")
    execute_process(COMMAND "nc-config" "--includedir"
        OUTPUT_VARIABLE C_NETCDF_INCLUDE_DIR)
    execute_process(COMMAND "nc-config" "--libs"
        OUTPUT_VARIABLE C_NETCDF_LIBRARIES)
    # remove \n at the end of the above variables
    string(STRIP "${C_NETCDF_INCLUDE_DIR}" C_NETCDF_INCLUDE_DIR)
    string(STRIP "${C_NETCDF_LIBRARIES}" C_NETCDF_LIBRARIES)

    execute_process(COMMAND "nf-config" "--includedir"
        OUTPUT_VARIABLE FORTRAN_NETCDF_INCLUDE_DIR)
    execute_process(COMMAND "nf-config" "--flibs"
        OUTPUT_VARIABLE FORTRAN_NETCDF_LIBRARIES)
    if (FORTRAN_NETCDF_INCLUDE_DIR STREQUAL "" OR FORTRAN_NETCDF_LIBRARIES STREQUAL "")
        message(STATUS "Command nf-config was not found")
        set(BUILD_FORTRAN OFF)
    else()
        string(STRIP "${FORTRAN_NETCDF_INCLUDE_DIR}" FORTRAN_NETCDF_INCLUDE_DIR)
        string(STRIP "${FORTRAN_NETCDF_LIBRARIES}" FORTRAN_NETCDF_LIBRARIES)
    endif()

    set(NETCDF_INCLUDE_DIRS ${C_NETCDF_INCLUDE_DIR} ${FORTRAN_NETCDF_INCLUDE_DIR})
    set(NETCDF_LIBRARIES ${C_NETCDF_LIBRARIES} ${FORTRAN_NETCDF_LIBRARIES})
    if (NOT BUILD_FORTRAN)
        message(STATUS "Will not build Fortran interface")
    endif()
endif()

if ("${NETCDF_INCLUDE_DIRS}" STREQUAL "" OR "${NETCDF_LIBRARIES}" STREQUAL "")
    message(STATUS "*******************************************************")
    message(STATUS "Unable to infer the location of NetCDF!")
    message(STATUS "Either:")
    message(STATUS "1) Specify -DNETCDF_INCLUDE_DIRS:PATH=<dir>")
    message(STATUS "           -DNETCDF_LIBRARIES=\"-L<dir> [-lnetcdff] -lnetcdf\"")
    message(STATUS "   (adding -lhdf5_hl -lhdf5 -ldl -lm -lz -lcurl and other libraries if needed)")
    message(STATUS "--or--")
    message(STATUS "2) Make sure to have nc-config [and optionally nf-config] in your PATH")
    message(STATUS "   so that NETCDF_INCLUDE_DIRS and NETCDF_LIBRARIES can be inferred")
    message(FATAL_ERROR "*******************************************************")
else()
	message(STATUS "NETCDF_INCLUDE_DIRS: ${NETCDF_INCLUDE_DIRS}")
	message(STATUS "NETCDF_LIBRARIES: ${NETCDF_LIBRARIES}")
endif()
include_directories(${NETCDF_INCLUDE_DIRS})


add_subdirectory(src)
add_subdirectory(tests)

