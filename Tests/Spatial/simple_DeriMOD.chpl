use StencilArray;
use DerivativeMod;
use Time;



var A = new StenArray((10,10));
for i in A.Dom do {
    A.arr[i] = (i[0]*10+i[1]):real;
}

// var left:domain(2) = {1..10,1..1};
// var right:domain(2) = {1..10,10..10};
// var top:domain(2) = {1..1,1..10};
// var down:domain(2) = {10..10,1..10};

// writeln(A.arr[left]);
writeln(A.arr);
writeln("----------------------------------------------------");
A = mixed_derivative(A,scheme="forward",d={1..10,1..3},order=1,accuracy=2,step=1,1);
A = mixed_derivative(A,scheme="backward",d={1..10,7..10},order=1,accuracy=2,step=1,1);
A = mixed_derivative(A,scheme="central",d={1..10,4..6},order=1,accuracy=2,step=1,1);
writeln(A.arr);
