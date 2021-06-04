use StencilArray;
use DerivativeMod;
use Time;



var A = new StenArray((10,10));
for i in A.Dom do {
    A.arr[i] = i[0]*10+i[1];
}

var left:domain(2) = {1..10,1..1};
var right:domain(2) = {1..10,10..10};
var top:domain(2) = {1..1,1..10};
var down:domain(2) = {10..10,1..10};

writeln(A.arr[left]);

// mixed_derivative(A,"forward",{1..2,2..4},1,2,0.3,0);
// mixed_derivative(A,"backward",{1..2,2..4},1,2,0.3,0);
// mixed_derivative(A,"central",{1..2,2..4},1,2,0.3,0);
