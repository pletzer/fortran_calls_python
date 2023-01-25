# fortran_calls_python

This project shows how to call Python from Fortran using the instrinsic function 
`execute_command_line`, which is available in Fortran 2008. The command invokes
a Python code which takes an input NetCDF file and produces an output 
NetCCDF file. 

## Build the example

On mahuika:
```
ml intel CMake netCDF-Fortran Python
```
To compile:
```
mkdir build
cd build
FC=ifort cmake ..
make
```

## Test the code

```
ctest
```

## How to run the test driver
```
tests/test_driver
```




