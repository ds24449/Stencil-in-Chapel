/*
    A simple test script checking derivative of sinx 
*/


use IO; // To make a graph in python
use StencilArray;
use linspace;
use DerivativeMod;

var saveFile = open("Tests/Data/sinAvgError_Values.txt",iomode.cw);
var saveFileWriter = saveFile.writer();

config var start = 100;
config var end = 1000;
config var step = start;

var errors:[1..end/start] real;

for n in start..end by step{
    var sinArray = new StenArray((n,),padding=1);
    var cosArray = new StenArray((n,),padding=0);

    var grid:[1..n] real = linspace(0,2*pi,n,false);

    var h = grid[2]-grid[1];

    forall i in sinArray.Dom do {
        sinArray.arr[i] = sin(grid[i]);
    }

    Apply_Bounds(sinArray,"periodic"); // Apply Boundary Condition
    //Check for boundary conditions
    assert(sinArray.arr[0] == sinArray.arr[n]);
    assert(sinArray.arr[n+1] == sinArray.arr[1]);
    
    forall i in cosArray.Dom do {
        cosArray.arr[i] = cos(grid[i]);
    }

    var result = central_diff(sinArray,order=1,accuracy=2,step=h,axis=0);

    var avgError:real = 0.0;
    for i in result.Dom{
        avgError += abs(result.arr[i]-cosArray.arr[i]);
    }
    avgError /= n;
    errors[n/start] = avgError;

    if(n/end == 1) then saveFileWriter.writeln(h);
    else saveFileWriter.write(h," ");
}

saveFileWriter.writeln(errors);
saveFileWriter.close();
saveFile.fsync();
saveFile.close();
