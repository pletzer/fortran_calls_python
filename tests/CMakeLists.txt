include_directories(
  ${CMAKE_BINARY_DIR}/src
  ${CMAKE_Fortran_MODULE_DIRECTORY}
)

configure_file(test_driver.f90.in ${CMAKE_BINARY_DIR}/test_driver.f90)

add_executable(test_self_descr_array test_self_descr_array.f90)
set_target_properties(test_self_descr_array PROPERTIES LINKER_LANGUAGE Fortran)
target_link_libraries(test_self_descr_array fortran2python ${NETCDF_LIBRARIES})

add_executable(test_driver ${CMAKE_BINARY_DIR}/test_driver.f90)
set_target_properties(test_driver PROPERTIES LINKER_LANGUAGE Fortran)
target_link_libraries(test_driver fortran2python ${NETCDF_LIBRARIES})

add_test(NAME self_descr_array COMMAND test_self_descr_array)
add_test(NAME driver COMMAND test_driver)
