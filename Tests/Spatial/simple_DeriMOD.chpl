// // Required Imports
// use StencilArray;
// use DerivativeMod;
// use Time;

// var A = new StenArray((10,10));
// for i in A.Dom do {
//     A.arr[i] = (i[0]*10+1):real;
// }

// var result = new StenArray(A);

// writeln(A.arr);
// writeln("----------------------------------------------------");
// mixed_derivative(A,result,scheme="forward",d={1..10,1..3},order=1,accuracy=2,step=1,1);
// writeln("----------------------------------------------------");
// writeln(central_diff(A,1,2,1,1).arr);
// writeln("----------------------------------------------------");
// mixed_derivative(A,result,scheme="backward",d={1..10,7..10},order=1,accuracy=2,step=1,1);
// mixed_derivative(A,result,scheme="central",d={1..10,4..6},order=1,accuracy=2,step=1,1);
// writeln(result.arr);


/*
    A simple test script checking derivative of sinx 
    chpl --module-dir src/ Tests/Spatial/sinAvgError.chpl && ./sinAvgError
*/


use IO; // To make a graph in python
use StencilArray;
use DerivativeMod;
use linspace;

var saveFile = open("Tests/Data/sinAvgError.txt",iomode.cw);
var saveFileWriter = saveFile.writer();

config var start = 100;
config var end = 1000;
config var step = start;

var errors:[1..end/start] real;

for n in start..end by step{
    var sinArray = new StenArray((n,),padding=2); // An StenArray object with dimension (n-1x1)
    var cosArray = new StenArray((n,));

    var grid:[1..n] real = linspace(0,2*pi,n,false);

    var h = grid[2]-grid[1];

    forall i in sinArray.Dom do {
        sinArray.arr[i] = sin(grid[i]);
    }
    
    Apply_Bounds(sinArray,"periodic");
    assert(sinArray.arr[0] == sinArray.arr[n]);
    assert(sinArray.arr[n+1] == sinArray.arr[1]);
    
    forall i in cosArray.Dom do {
        cosArray.arr[i] = cos(grid[i]);
    }

    var result = new StenArray(sinArray,false);
    mixed_derivative(sinArray,result,scheme="forward",d={1..5},order=1,accuracy=1,step=h,0);
    mixed_derivative(sinArray,result,scheme="backward",d={n-5..n},order=1,accuracy=1,step=h,0);
    mixed_derivative(sinArray,result,scheme="central",d={6..n-6},order=1,accuracy=2,step=h,0);

    var avgError:real = 0.0;
    for i in result.Dom{
        avgError += abs(result.arr[i]-cosArray.arr[i]);
    }
    avgError /= n;

    //writeln("n,avgError = ",n,",",avgError);

    errors[n/start] = avgError;

    if(n/end == 1) then saveFileWriter.writeln(h);
    else saveFileWriter.write(h," ");
}

saveFileWriter.writeln(errors);
saveFileWriter.close();
saveFile.fsync();
saveFile.close();
