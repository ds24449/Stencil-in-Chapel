// chpl --module-dir src/ Tests/sphinx_solvingPDE.chpl
/*
    we will solve PDE: 
    du/dt = d2u/dx2 + g(x,t)

    x = (0,L), t = (0,T]

    u(x,0) = I(x) --- Initial Condition
    u(0,t) = S(t) -- Boundary Condition
    u(L,t) = 0 -- Boundary Condition

    Assume U(x,t) = (3t+2)(x - L)
    then, 
    g(x,t) = 3(x-L),  s(t) = -L(3t+2),   I(x) = 2(x-L)
*/

use DataArray;
use FiniteDifference;
use Time_Stepper;
use linspace;
use List;
use IO;

// Parameters 
config const L:real = 0.5;  // Length
config const N:int = 20;     // Number of elements
config const beta:real = 8.2E-5;
config const dt:real = 0.00034375;
config const T = 1*60;

const x = linspace(0,L,N+1);
const dx = x[2]-x[1];

proc dsdt(t:real){
    return 0.0; // L is global
}

proc u_exact(x:real,t:real){
    return (3*t + 2)*(x - L);
}

proc dudx(t:real){
    return 0.0;
}

proc s(t:real){
    return 323.0;
}

proc g(x:real,t:real){
    return 0.0;
}

proc rhs(u:shared AbstractDataArray,in t:real){
    var old_rh = u:DataArray(real,1,false);
    var N = old_rh.arr.domain.high-1; // assuming u is 1-Dimensional
    var rh = new shared DataArray(old_rh.arr,old_rh.dimensions);
    
    var Solver = new FDSolver(old_rh);
    Solver.dom = {1..N-1};
    
    rh = Solver.Finite_Difference(scheme = "central",order = 2,accuracy = 2,step = dx,axis = 0);
    rh.arr = beta*rh.arr;
    
    rh.arr[0] = dsdt(t);
    rh.arr[N] = (beta/dx**2)*(old_rh.arr[N-1] + 2*dx*dudx(t) - 2*old_rh.arr[N]) + g(x[N],t);

    forall i in 1..N-1{
        rh.arr[i] += g(x[i],t);
    }

    return rh:AbstractDataArray;
}

var U_0 = new shared DataArray(real,{0..N+1},{"X"});
U_0.arr[0] = s(0);
forall i in 1..N+1 {
    U_0.arr[i] = 283.0;
}

var results;
results = ForwardEuler(rhs,U_0,dt,T=T);
writeln(round(T/dt):int);
writeln(results.size);
var saveFile = open("Tests/Data/hotrod.txt",iomode.cw);
var saveFileWriter = saveFile.writer();


saveFileWriter.writeln(x);
var count = 0;
for i in results{
    count+=1;
    if(count%10000 == 0){
        var temp = i:DataArray(real,1,false);
        saveFileWriter.writeln(temp.arr);
    }
}
saveFileWriter.close();
saveFile.fsync();
saveFile.close();
