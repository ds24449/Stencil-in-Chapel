/*
    A simple test script checking derivative of sinx 
*/



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


config const n = 1000;
var dims = (n,);
var sinArray = new StenArray(dims,fluffX = 2);
var cosArray = new StenArray(dims);

assert(sinArray.ProblemSpace.rank == dims.size);

var values:[1..n] real = linspace(0,2*pi,n);
var dx = (2*pi)/n;
writeln("h = ",dx);

forall i in sinArray.ProblemSpace do {
    sinArray.arr[i] = sin(values[i]);
}
sinArray.arr[0] = sin(0-dx);
sinArray.arr[1001] = sin(values[1000]+dx);
sinArray.arr.updateFluff();

forall i in cosArray.ProblemSpace do{
    cosArray.arr[i] = cos(values[i]);
}

var result = sinArray.derivative((-1,0,1),-1..1);
result.arr = result.arr/(2*dx);
writeln("Sin' = ",result.arr[1],", Cos = ",cosArray.arr[1]);


var maxDiff = 0.0;
for i in result.ProblemSpace{
    maxDiff = max(maxDiff,abs(result.arr[i]-cosArray.arr[i]));
}
writeln(maxDiff," ---- ",dx*dx);
