cmake_minimum_required (VERSION 3.2)

# give the project a name and specify which languages to use
# if you don't specify the languages here it will default to C and C++
project(fortran2python LANGUAGES Fortran)

# create a shared library
add_library(fortran2python SHARED src/self_descr_array_mod.f90)
