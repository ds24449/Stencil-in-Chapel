use DataArray;
var grid:[1..10,1..10] real;
forall i in grid{
    i = 11.0;
} 

var orig = new unmanaged DataArray(grid,{"X"});
var share = orig;

writeln(orig.type:string);
writeln(share.type:string);

share.arr[1,1] = 12;
writeln(orig.arr[1,1]);
writeln(share.arr[1,1]);