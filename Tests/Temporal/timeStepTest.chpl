use StencilArray;
use DerivativeMod;
use Time_Stepper;
use IO;

var saveFile = open("Tests/Data/timestepvalues.txt",iomode.cw);
var writer = saveFile.writer();

var IVP = 1;

var grid:[1..10] real;
forall i in grid.domain do grid[i] = i*0.5;

var y_real:[1..10] real;
forall i in grid.domain do y_real[i] = exp(-10*grid[i]);

writer.writeln(grid);
writer.writeln(y_real);

var h_values = (0.05,0.01,0.001);

for i in h_values{
    var tot_values = ceil(5/i);
    writeln(tot_values);
    var result:[0..tot_values:int] real;
    result[0] = 1.0;
    var grid_spec:[0..tot_values:int] real;
    
    forall j in grid_spec.domain do grid_spec[j] = j*i; 
    forall j in 1..result.domain.high do result[j] = EulerMethod(result[j-1],-10*i);
    
    writer.writeln(grid_spec);
    writer.writeln(result);
} 
// writeln(A.arr.type:string);