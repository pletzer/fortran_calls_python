import numpy as np
import xarray as xr
import defopt
import tartes

def process(*, inputfile: str, outputfile: str):

    # open the input file
    ds = xr.open_dataset(inputfile)

    # read the input data
    wavelengths = ds['wavelengths'].data
    ssa = ds['ssa'].data
    density = ds['density'].data
    thickness = ds['thickness']

    # compute
    albedo = tartes.albedo(wavelengths, ssa, density, thickness)

    # save the output
    ds_out = xr.Dataset({'albedo': albedo})
    ds_out.to_netcdf(outputfile)

if __name__ == '__main__':
    defopt.run(process)
