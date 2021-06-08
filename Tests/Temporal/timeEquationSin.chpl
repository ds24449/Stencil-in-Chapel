// Temporal Step -> k
// Spatial Step -> h

// Need to check for u_t + k*u_x = alpha*u_xx
// 0<=x<=1
// 0<=t<=T


use DerivativeMod;
use linspace;
use StencilArray;
use Time_Stepper;
use IO;
use ntCDF;

var saveFile = open("/e/Stencil-in-Chapel/Tests/Data/sinWaveTime.txt",iomode.cw);
var writer = saveFile.writer();

config var n = 1000;

var Array = new StenArray((n,));

var grid:[1..n] real = linspace(0,2*pi,n,false); 
writer.writeln(grid);

var h = grid[2]-grid[1];

forall i in Array.Dom do Array.arr[i] = sin(grid[i]);
Array.arr[0] = sin(grid[n]);
Array.arr[n+1] = sin(grid[1]);
// Apply_Bounds(Array,"periodic");

var udx = central_diff(Array,order=1,accuracy=2,step=h); //ivp 

var res = AdamBashfourth(udx.arr,timedelta=0.2,iterations=20);


for i in res.domain.dim(0) do{
    writer.writeln(res[i]);
}
