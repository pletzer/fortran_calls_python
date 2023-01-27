# fortran_calls_python

This project shows how to call Python from Fortran using the instrinsic function 
`execute_command_line`, which is available in Fortran 2008. The command invokes
a Python code which takes an input NetCDF file and produces an output 
NetCCDF file. 

## Build the example

On mahuika:
```
ml intel CMake netCDF-Fortran Python
pip install defopt --user
```
Also, you will need to install tartes and dependencies:
```
git clone https://github.com/ghislainp/tartes.git
cd tartes
pip install . --user
```

To compile:
```
mkdir build
cd build
FC=ifort cmake -D CMAKE_INSTALL_PREFIX=<path to directory> ..
make
```

```
make install
```
will install the libfortran2python.so library into the directory specified by `CMAKE_INSTALL_PREFIX`.

## Test the code

```
ctest
```

## How to run the test driver
```
tests/test_driver
```




