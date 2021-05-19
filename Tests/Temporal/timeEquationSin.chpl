// Temporal Step -> k
// Spatial Step -> h

// Need to check for u_t + k*u_x = alpha*u_xx
// 0<=x<=1
// 0<=t<=T
// where u(x,t=0) = exp(-((x-2)**2)/8)
// u(0,t) = g_o(t)
// u(1,t) = g_1(t)

// g_0(t) = sqrt(20/(20+t))*exp(-(5+4t)**2/(10*(t+20)))
// g_1(t) = sqrt(20/(20+t))*exp(-2*(5+2t)**2/(5*(t+20)))


// exact solution is given by 
// u(x,t) = (0.025/sqrt(0.000625+0.02t))*exp(-(x+0.5-t)**2/(0.00125+0.04t))


use DerivativeMod;
use linspace;
use StencilArray;
use Time_Stepper;
use IO;
use NetCDF;

var saveFile = open("/e/GT_chpl/sinWaveTime.txt",iomode.cw);
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

var udx = central_diff(Array,0,2,step=h); //ivp 

var res = AdamBashfourth(udx.arr,timedelta=0.2,iterations=20);


for i in res.domain.dim(0) do{
    writer.writeln(res[i]);
}
