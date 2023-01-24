include_directories(
  ${CMAKE_BINARY_DIR}/src
  ${CMAKE_Fortran_MODULE_DIRECTORY}
)

add_executable(test_self_descr_array test_self_descr_array.f90)
set_target_properties(test_self_descr_array PROPERTIES LINKER_LANGUAGE Fortran)
target_link_libraries(test_self_descr_array fortran2python ${NETCDF_LIBRARIES})

add_test(NAME self_descr_array COMMAND test_self_descr_array)