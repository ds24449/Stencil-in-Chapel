proc myfunc(x:real){ return x; }
proc leftFunc(x:real) {return 1.0;}
proc rightFunc(x:real) {return 1.0;}
// var f = myfunc;
// writeln(myfunc.type:string);  // outputs: 4

proc what(x:func(real,real)) { return 1; }
writeln(what(myfunc));

// var z:["left","right"] func(real,real) = {leftFunc,rightFunc};
var z:(string,func(real,real)) = ("left",leftFunc);

writeln(z);
writeln(z[1](2.0));


var y:[1..10] int = 2;
y = 2*y;
writeln(y);