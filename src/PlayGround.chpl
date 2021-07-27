use Map;

// This enum is designed to distinguish between 'int', 'real', and 'bool' types
enum myTypes { i, r, b };

// This helper function converts from a type to one of the above enum values
proc typeToEnum(type t) {
  select t {
    when int do
      return myTypes.i;
    when real do
      return myTypes.r;
    when bool do
      return myTypes.b;
    otherwise
      compilerError("Unexpected type in typeToEnum()");
  }
}

class Abstract {
  // This stores information sufficient for determining a concrete
  // subclass's static type
  var concType: myTypes;

  // This is its initializer
  proc init(type t) {
    this.concType = typeToEnum(t);
  }

  // This is a dynamically dispatched method
  proc printMe() {
    writeln("I am a generic Abstract class");
  }
}
// This is a concrete class that contains everything important through
// generic fields
class Concrete: Abstract {
  type t;    // the type of elements stored
  var x: t;  // an example element of that type

  // The class's initializer
  proc init(x) {
    super.init(x.type);
    this.t = x.type;
    this.x = x;
  }

  override proc printMe() {
    writeln("I am a Concrete class with type ", t:string, " and value ", x);
  }

  proc getValue() {
    return x;
  }
}


proc foo(a:shared Abstract) {
  // Let's cast it to the appropriate static sub-type and do something with it:
  select a.concType {
    when myTypes.i {
      const c = a:Concrete(int);
      bar(c);
    }
    when myTypes.r {
      const c = a:Concrete(real);
      bar(c);
    }
    when myTypes.b {
      const c = a:Concrete(bool);
      bar(c);
    }
    otherwise {
      halt("Unexpected type");
    }
  }
}

// This version of bar() takes a concrete class and does something
// taking advantage of its concrete-ness
//
proc bar(c: Concrete(?)) {
  writeln("In bar, c's type is: ", c.type:string);
  var val = c.getValue();
  writeln("In foo, c's value is: ", val, " : ", val.type:string);
}

// writeln(foo.type:string);

proc zoo(arg0:foo.type,arg1:Concrete){
  var b = arg1:Abstract;
  foo(b);
}

var a = new shared Concrete(2.3);
zoo(foo,a);