/*
    A simple test script checking derivative of sinx 
    chpl --module-dir src/ Tests/Spatial/sincos2DAvgError.chpl && ./sincos2DAvgError
*/
use IO; // To make a graph in python
use DataArray;
use FiniteDifference;
use linspace;
// use ntCDF; // EDIT THIS

var saveFile = open("Tests/Data/sincos2DAvgError.txt",iomode.cw);
var saveFileWriter = saveFile.writer();

config var start = 100;
config var end = 1000;
config var step = start;

var errors:[1..end/start] real;

for n in start..end by step{
    var sincos = new owned DataArray(eltType = real,size = {1..n,1..n},dimensions = {"Y","X"}); // An StenArray object with dimension (n-1x1)
    var trueValue = new owned DataArray(eltType = real,size = {1..n,1..n},dimensions = {"Y","X"});

    var grid:[1..n] real = linspace(0,2*pi,n,false);
    var h = grid[2]-grid[1];

    forall i in 1..n do {
        for j in 1..n do{
            sincos.arr[i,j] = sin(grid[j])*cos(grid[i]);//Sin(x)*Cos(y)
        }
    }
    
    forall i in 1..n do {
        for j in 1..n do{
            trueValue.arr[i,j] = -sin(grid[i])*sin(grid[j]) + cos(grid[i])*cos(grid[j]);
        }
    }

    // var result = new StenArray(sincos,false);
    // mixed_derivative(sincos,result,scheme="forward",d={1..5},order=1,accuracy=1,step=h,0);
    // mixed_derivative(sincos,result,scheme="backward",d={n-5..n},order=1,accuracy=1,step=h,0);
    // mixed_derivative(sincos,result,scheme="central",d={6..n-6},order=1,accuracy=2,step=h,0);

    var Solver = new owned FDSolver(sincos);
    Solver.apply_boundary(["Y" => "periodic","X" => "periodic"]);
    var result = Solver.Finite_Difference(scheme="central",order=1,accuracy=2,step=h,axis=0..1);

    var avgError:real = 0.0;
    for i in result.dom{
        avgError += abs(result.arr[i]-trueValue.arr[i]);
    }
    avgError /= n*n;

    errors[n/start] = avgError;

    if(n/end == 1) then saveFileWriter.writeln(h);
    else saveFileWriter.write(h," ");
}

saveFileWriter.writeln(errors);
saveFileWriter.close();
saveFile.fsync();
saveFile.close();
