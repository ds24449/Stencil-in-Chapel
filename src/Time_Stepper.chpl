use StencilArray;
use StencilDist;

// Adam Bashforth Time Stepper 
proc AdamBashfourth(initial_value,timedelta:real,order:int(8) = 3,iterations:int(64) = 1){
    // if(order == 3){
    return third_bashfourth(initial_value,timedelta,iterations+2);
    //}
}

proc third_bashfourth(initial_value,timedelta:real,iterations){

    // y(n+3) = y(n+2) + h/12 * (23 * f(t(n+2),y(n+2)) - 16 * f(t(n+1),y(n+1)) + 5 * f(t(n),y(n)))
    // So here **initial_value** must be the function *f* evaluated at t_n,y_nt
    
    var result: [0..iterations] initial_value.type;
    result[0] = initial_value;

    for i in 1..iterations do {
        if(i == 1){ //y1
            result[i] = (ForwardEuler(result[0],timedelta)); //TODO: Change this according to upddated ForwardEuler method
        }else if(i == 2){ //y2
            result[i] = (result[i-1] + (timedelta/2)*(3*result[i-1]-result[i-2]));
        }else{ //y3
            result[i] = (result[i-1] + (timedelta/12)*(23.0*result[i-1] - 16.0*result[i-2] + 5.0*result[i-3]));
        }
    }
    return result;    
}

var temp2 = new StenArray((10,));
var temp:[0..11] real = temp2.arr;
proc funcs(A:temp.type, B:real) { return A; }

// writeln(temp.type:string);
writeln(funcs.type:string);


// ! As can be seen here we need to declare another temp variable and then a dummy function to enable FirstClass Citizen conditions,
// ! This can be made viable using a Time Stepper class which has to initialized with type of Variable it will be using at run-time
proc ForwardEuler(F:funcs.type,U_0,dt:real,T:real){
    // Here We should not allow U_0 to be StenArray because it causes problems in default-initialization of result;
    // Might Need to add some method for default init of StenArray
    // or Convert Arrays to StenArray objects
    var N_t = round(T/dt):int;
    var result: [0..N_t] U_0.type;
    var t = linspace(0,N_t*dt,N_t+1);
    result[0] = U_0;

    for i in 0..<N_t{
        // result[i+1] = new StenArray(U_0,true); //! Be Careful, here we assumed that U_0 is StenArray
        result[i+1] = result[i] + dt * F(result[i],t[i]);
    }
    return result;

}