import numpy as np
import xarray as xr
import defopt

def process(*, inputfile: str, outputfile: str):
	# example of a python code that takes an input, processes the data and
	# saves the result in the output file
	ds = xr.open_dataset(inputfile)

	z = np.empty([2,], np.float64)
	z[0] = np.sum(ds['a']) + np.sum(ds['b'])
	z[1] = np.prod(ds['a'] + 1) + np.prod(ds['b'] + 1)

	ds_out = xr.Dataset({'z': z})
	ds_out.to_netcdf(outputfile)

if __name__ == '__main__':
	defopt.run(process)
