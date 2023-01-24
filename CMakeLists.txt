cmake_minimum_required (VERSION 3.2)

# give the project a name and specify which languages to use
# if you don't specify the languages here it will default to C and C++
project(fortran2python LANGUAGES Fortran)

enable_language(Fortran)
enable_testing()

add_subdirectory(src)
add_subdirectory(tests)

