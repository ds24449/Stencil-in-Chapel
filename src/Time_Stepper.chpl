use DataArray;
use linspace;
use List;

// class Time_Stepper{


// }

// // Adam Bashforth Time Stepper 
// proc AdamBashfourth(initial_value,timedelta:real,order:int(8) = 3,iterations:int(64) = 1){
//     // if(order == 3){
//     return third_bashfourth(initial_value,timedelta,iterations+2);
//     //}
// }

// proc third_bashfourth(initial_value,timedelta:real,iterations){

//     // y(n+3) = y(n+2) + h/12 * (23 * f(t(n+2),y(n+2)) - 16 * f(t(n+1),y(n+1)) + 5 * f(t(n),y(n)))
//     // So here **initial_value** must be the function *f* evaluated at t_n,y_nt
    
//     var result: [0..iterations] initial_value.type;
//     result[0] = initial_value;

//     for i in 1..iterations do {
//         if(i == 1){ //y1
//             result[i] = (ForwardEuler(result[0],timedelta)); //TODO: Change this according to upddated ForwardEuler method
//         }else if(i == 2){ //y2
//             result[i] = (result[i-1] + (timedelta/2)*(3*result[i-1]-result[i-2]));
//         }else{ //y3
//             result[i] = (result[i-1] + (timedelta/12)*(23.0*result[i-1] - 16.0*result[i-2] + 5.0*result[i-3]));
//         }
//     }
//     return result;    
// }


// ! As can be seen here we need to declare another temp variable and then a dummy function to enable FirstClass Citizen conditions,
// ! This can be made viable using a Time Stepper class which has to initialized with type of Variable it will be using at run-time




proc ForwardEuler(rhs:func(shared AbstractDataArray,real,shared AbstractDataArray),in U_0:shared DataArray,dt:real,T:real){

    var N_t = round(T/dt):int;
    var t = linspace(0,T,N_t+1);
    
    var result = new shared DataArray(U_0.arr,U_0.dimensions);
    var result_abs = result:AbstractDataArray;
    var result_list:list(shared AbstractDataArray);

    for i in 1..N_t{
        result_abs = result:AbstractDataArray;
        var rez:AbstractDataArray = rhs(result_abs,t[i]); // f(x,t)
        var tmprez = rez:DataArray(real,1,false); //Because Return Value is AbstractDA
        tmprez.arr = tmprez.arr * dt;
        result = result + tmprez;   //  result = result + dt*f(x,t)
        result_list.append(result);
    }
    return result_list;
}