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

config const L:real = 1.5;
config const N:int = 4;
config const beta:real = 0.5;
config const dt:real = 0.1;

const mesh:[1..N] real = linspace(0,L,N);
const dx = mesh[2]-mesh[1];
var U_0 = new shared DataArray(real,{0..N+1},{"X"});
U_0.arr[0] = u_exact(0,0);

proc dsdt(t:real){
    return 3*(-L); // L is global
}

proc u_exact(x:real,t:real){
    return (3*t + 2)*(x - L);
}

proc dudx(t:real){
    return (3*t + 2);
}

proc s(t:real){
    return u_exact(0,t);
}

proc g(x:real,t:real){
    return 3*(x - L);
}

proc rhs(u:shared AbstractDataArray,in t:real){
    var old_rh = u:DataArray(real,1,false);
    var N = old_rh.arr.domain.high-1; // assuming u is 1-Dimensional
    var rh = new shared DataArray(old_rh.arr,old_rh.dimensions);

    rh.arr[0] = dsdt(t);
    rh.arr[N+1] = 2*dx*dudx(t); // dx here is also global

    var Solver = new FDSolver(rh);
    Solver.dom = {1..N};

    rh = Solver.Finite_Difference(scheme = "central",order = 2,accuracy = 2,step = dx,axis = 0);
    rh.arr = beta*rh.arr;

    forall i in rh.dom{
        rh.arr[i] += g(mesh[i],t);
    }

    return rh:AbstractDataArray;
}

forall i in 1..N {
    U_0.arr[i] = u_exact(mesh[i],0);
}

var results;
results = ForwardEuler(rhs,U_0,dt,T=1.2,dx);

// Checking accuracy
var T = 1.2;
var N_t = round(T/dt):int;
var t = linspace(0,T,N_t+1);

for i in 1..N{
    writeln(u_exact(mesh[i],t[i]) - results.arr[i]);
}