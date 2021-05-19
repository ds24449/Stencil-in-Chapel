/*
    A simple test script checking derivative of sinx 
*/


use IO; // To make a graph in python
use StencilArray;

iter linspace(type dtype, start, stop, num, in endpoint:bool=true) {
    assert(num > 0, "number of points must be > 0");
    if num==1 then endpoint = false;
    const ninterval = (if endpoint then num-1 else num):real;
    const dt = (stop-start)/ninterval;

    for i in 0..#num do yield (start+i*dt):dtype;
}
iter linspace(start, stop, num, endpoint=true) {
    for x in linspace(real(64), start, stop, num, endpoint) do yield x;
}
var saveFile = open("/e/GT_chpl/Tests/sinAvgError_Values.txt",iomode.cw);
var saveFileWriter = saveFile.writer();

config var start = 100;
config var end = 1000;
config var step = start;

var errors:[1..end/start] real;

for n in start..end by step{
    var sinArray = new StenArray((n-1,),padding=1);
    var cosArray = new StenArray((n-1,),padding=1);

    var grid:[1..n] real = linspace(0,2*pi,n);

    var h = grid[2]-grid[1];

    forall i in sinArray.Dom do {
        sinArray.arr[i] = sin(grid[i]);
    }

    sinArray.arr[0] = sin(grid[n-1]);
    sinArray.arr[n] = sin(grid[1]);
    
    forall i in cosArray.Dom do {
        cosArray.arr[i] = cos(grid[i]);
    }

    // var result = sinArray.derivative((-1,0,1),-1..1);
    // result.arr = result.arr/(2*h);

    var result = central_diff(sinArray,0,2,step=h);

    var avgError:real = 0.0;
    for i in result.Dom{
        avgError += abs(result.arr[i]-cosArray.arr[i]);
    }
    avgError /= n;

    // writeln("n,avgError = ",n,",",avgError);

    errors[n/start] = avgError;

    if(n/end == 1) then saveFileWriter.writeln(h);
    else saveFileWriter.write(h," ");
}

saveFileWriter.writeln(errors);
saveFileWriter.close();
saveFile.fsync();
saveFile.close();
