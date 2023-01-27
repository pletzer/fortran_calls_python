configure_file(tartes_albedo.f90.in ${CMAKE_BINARY_DIR}/src/tartes_albedo.f90)

# create a shared library
set(SRC self_descr_array_mod.f90 ${CMAKE_BINARY_DIR}/src/tartes_albedo.f90)

add_library(fortran2python SHARED ${SRC})
target_link_libraries(fortran2python ${NETCDF_LIBRARIES})



