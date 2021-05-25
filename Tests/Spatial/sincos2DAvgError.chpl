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
    forall i in 1..n{
        ques.arr[i,0] = ques.arr[i,n];
        ques.arr[i,n+1] = ques.arr[i,1];
    }
    forall j in 1..n{
        ques.arr[0,j] = ques.arr[n,j];
        ques.arr[n+1,j] = ques.arr[1,j]; 
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

    // writeln("n,avgError = ",n,",",avgError);
    // writeln("True vs Calculated = ",trueValues.arr[1,1]," , ",result.arr[1,1]);

    errors[n/start] = avgError;

    if(n/end == 1) then saveFileWriter.writeln(h);
    else saveFileWriter.write(h," ");

    // Create .nc files for both true and false values
    if(n == end) then {
        write2DStenArray(result,end,end,"Tests/Data/result.nc");
        write2DStenArray(trueValues,end,end,"Tests/Data/true.nc");
    }
}

saveFileWriter.writeln(errors);
saveFileWriter.close();
saveFile.fsync();
saveFile.close();