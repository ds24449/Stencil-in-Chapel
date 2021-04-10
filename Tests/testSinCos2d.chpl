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


config const x = 100;
config const y = 100;

var valuesX:[1..x] real = linspace(0,2*pi,x);
var valuesY:[1..y] real = linspace(0,2*pi,y);
var dx = (2*pi)/x;

var ques:StenArray = new StenArray((x,y),fluffX=2,fluffY=2);
for i in 1..x{
    for j in 1..y{
        ques.arr[i,j] = sin(valuesX[i])*cos(valuesY[j]);  //Sin(x)*Cos(y)
    }
}
var trueValues:StenArray = new StenArray(ques);
for i in 1..x{
    for j in 1..y{
        trueValues.arr[i,j] = cos(valuesX[i])*cos(valuesY[j]) - sin(valuesX[i])*sin(valuesY[j]);
    }
}

var calculatedValues:StenArray = ques.derivative2D(((-1,0,1),(-1,0,1)),(-1..1,-1..1),(0,1));
writeln(trueValues.arr[10,10],",",calculatedValues.arr[10,10]/(2*dx));
// TO RUN THE TEST FILE
// chpl --module-dir /e/Stencil-in-Chapel/ /e/Stencil-in-Chapel/Tests/testSinCos2d.chpl