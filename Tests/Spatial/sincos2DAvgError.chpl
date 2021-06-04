// chpl --module-dir src/ Tests/Spatial/sincos2DAvgError.chpl -I/usr/include -L/usr/lib/x86_64-linux-gnu && ./sincos2DAvgError

use IO;
use StencilArray;
use DerivativeMod;
use linspace;
use ntCDF;

var saveFile = open("Tests/Data/sincos2DAvgError.txt",iomode.cw);
var saveFileWriter = saveFile.writer();


config var start = 100;
config var end = 1000;
config var step = start;

var errors:[1..end/start] real;

for n in start..end by step{

    var grid:[1..n] real = linspace(0,2*pi,n,false);
    var h = grid[2] - grid[1];

    var ques:StenArray = new StenArray((n,n),padding=1);
    for i in 1..n{
        for j in 1..n{
            ques.arr[i,j] = sin(grid[i])*cos(grid[j]);  //Sin(x)*Cos(y)
        }
    }

    
    Apply_Bounds(ques,"periodic");// Apply Boundary Conditions
    //Check for Boundary Conditions
    forall i in 1..n{
        assert(ques.arr[i,0] == ques.arr[i,n]);
        assert(ques.arr[i,n+1] == ques.arr[i,1]);
    }
    forall j in 1..n{
        assert(ques.arr[0,j] == ques.arr[n,j]);
        assert(ques.arr[n+1,j] == ques.arr[1,j]); 
    }

    var trueValues:StenArray = new StenArray(ques);
    for i in 1..n{
        for j in 1..n{
            trueValues.arr[i,j] = cos(grid[i])*cos(grid[j])-sin(grid[i])*sin(grid[j]);
        }
    }

    // Apply_Bounds(ques,"periodic");

    var result = central_diff(ques,order=1,accuracy=2,step=h,axis=1);
    result += central_diff(ques,order=1,accuracy=2,step=h,axis=0);

    var avgError:real = 0.0;
    for i in 1..n{
        for j in 1..n do {
            avgError += abs(result.arr[i,j]-trueValues.arr[i,j]);
        }
    }
    avgError /= n*n;

    errors[n/start] = avgError;

    if(n/end == 1) then saveFileWriter.writeln(h);
    else saveFileWriter.write(h," ");

    // Create .nc files for both true and false values
    if(n == end) then {
        var diff = new StenArray((end,end),padding=0);
        forall i in diff.Dom do diff.arr[i] = result.arr[i]-trueValues.arr[i];
        write2DStenArray(diff,end,end,"Tests/Data/diff.nc");
        write2DStenArray(result,end,end,"Tests/Data/result.nc");
        write2DStenArray(trueValues,end,end,"Tests/Data/true.nc");
    }
}

saveFileWriter.writeln(errors);
saveFileWriter.close();
saveFile.fsync();
saveFile.close();