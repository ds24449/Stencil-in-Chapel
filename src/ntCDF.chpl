// chpl --fast e/GT_chpl/netcdfWrite.chpl -I/usr/include -L/usr/lib/x86_64-linux-gnu
// Must have C_NetCDF library in the system, and use -I flag to provide path for header file
// and -L to provide path for library

use NetCDF.C_NetCDF;
use StencilArray;

proc cdfError(e:c_int) {
    if e != NC_NOERR {
        writeln("Error: ", nc_strerror(e): string);
        exit(2);
    }
}

proc write2DStenArray(T:StenArray,nx:int,ny:int,fileName:c_string,dataName:c_string = "data"){
    var ncid, xDimID, yDimID, varID: c_int;
    var dimIDs: [0..1] c_int;

    var W:[T.Dom] c_float;
    forall i in T.Dom do{
        W[i] = T.arr[i]: c_float;
    }

    cdfError(nc_create(fileName, NC_NETCDF4, ncid));
    cdfError(nc_def_dim(ncid, "x", nx: size_t, xDimID));
    cdfError(nc_def_dim(ncid, "y", ny: size_t, yDimID));

    dimIDs = [xDimID,yDimID];

    cdfError(nc_def_var(ncid,dataName,NC_FLOAT,2,dimIDs[0],varID));
    cdfError(nc_enddef(ncid));
    cdfError(nc_put_var_float(ncid,varID,W[1,1]));
    cdfError(nc_close(ncid));

    return 0;
}