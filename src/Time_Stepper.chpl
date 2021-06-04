use StencilArray;

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
            result[i] = (EulerMethod(result[0],timedelta));
        }else if(i == 2){ //y2
            result[i] = (result[i-1] + (timedelta/2)*(3*result[i-1]-result[i-2]));
        }else{ //y3
            result[i] = (result[i-1] + (timedelta/12)*(23.0*result[i-1] - 16.0*result[i-2] + 5.0*result[i-3]));
        }
    }
    return result;    
}



proc EulerMethod(curr_values,timedelta){
    return (curr_values + timedelta*curr_values);
}