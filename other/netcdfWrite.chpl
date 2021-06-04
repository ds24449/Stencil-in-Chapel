// chpl --fast e/GT_chpl/netcdfWrite.chpl -I/usr/include -L/usr/lib/x86_64-linux-gnu
use NetCDF.C_NetCDF;

proc cdfError(e) {
    if e != NC_NOERR {
    writeln("Error: ", nc_strerror(e): string);
    exit(2);
    }
}

config const nx = 300, ny = 300, h = 5.0;
var T: [1..nx, 1..ny] c_float, x, y: real;
var ncid, xDimID, yDimID, varID: c_int;
var dimIDs: [0..1] c_int; // two elements

for i in 1..nx do {
    x = (i-0.5)/nx*2*h - h; // square -h to +h on each side
    for j in 1..ny do {
        y = (j-0.5)/ny*2*h - h;
        T[i,j] = (sin(x*x-y*y)): c_float; 
    }
}

cdfError(nc_create("300x300.nc", NC_NETCDF4, ncid)); // const NC_NETCDF4 => file in netCDF-4 standard
cdfError(nc_def_dim(ncid, "x", nx: size_t, xDimID)); // define the dimensions
cdfError(nc_def_dim(ncid, "y", ny: size_t, yDimID));
dimIDs = [xDimID, yDimID]; // set up dimension IDs array
cdfError(nc_def_var(ncid, "density", NC_FLOAT, 2, dimIDs[0], varID)); // define the 2D data variable
cdfError(nc_def_var_deflate(ncid, varID, NC_SHUFFLE, deflate=1, deflate_level=9)); // compress 0=no 9=max
cdfError(nc_enddef(ncid)); // done defining metadata
cdfError(nc_put_var_float(ncid, varID, T[1,1])); // write data to file
cdfError(nc_close(ncid));
