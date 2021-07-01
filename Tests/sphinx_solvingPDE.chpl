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

use StencilArray;
use DerivativeMod;
use Time_Stepper;
use linspace;

config const L:real = 1.5;
config const N:int = 4;
config const beta:real = 0.5;
config const dt:real = 0.1;

const mesh:[1..N] real = linspace(0,L,N);
const dx = mesh[2]-mesh[1];
var U_0 = new StenArray((N,));
U_0.arr[0] = s(0);

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

proc rhs(u:U_0.arr.type,t:real){
    var N = u.domain.high; // assuming u is 1-Dimensional
    var rh = new StenArray((N,));
    rh.arr = u;

    rh.arr[0] = dsdt(t);
    rh.arr[N+1] = 2*dx*dudx(t); // dx here is also global

    rh = Finite_Difference(rh,scheme = "central",order = 2,accuracy = 2,step = dx);

    rh.arr = beta*rh.arr;
    forall i in rh.Dom{
        rh.arr[i] += g(mesh[i],t);
    }

    // return rh.arr;
    var res:[0..N+1] real = rh.arr;
    return res;
}

forall i in 1..N {
    U_0.arr[i] = u_exact(mesh[i],0);
}

var u;
var problemHERE:[0..N+1] real = U_0.arr[0..N+1];
// u = linspace(0,10,5);
u = ForwardEuler(rhs,problemHERE,dt,T=1.2);
// writeln(u.type:string);
// writeln(t.type:string);