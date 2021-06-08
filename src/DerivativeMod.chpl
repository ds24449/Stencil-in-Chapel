use StencilArray;
use List;

const weights = [
    [(0.0,0.0,0.0,-1.0/2,0.0,1.0/2,0.0,0.0,0.0),(0.0,0.0,1.0/12,-2.0/3,0.0,2.0/3,-1.0/12,0.0,0.0),(0.0,-1.0/60,3.0/20,-3.0/4,0.0,3.0/4,-3.0/20,1.0/60,0.0),(1.0/280,-4.0/105,1.0/5,-4.0/5,0.0,4.0/5,-1.0/5,4.0/105,-1.0/280)],
    [(0.0,0.0,0.0,1.0,-2.0,1.0,0.0,0.0,0.0),(0.0,0.0,-1.0/12,4.0/3,-5.0/2,4.0/3,-1.0/12,0.0,0.0),(0.0,1.0/90,-3.0/20,3.0/2,-49.0/18,3.0/2,-3.0/20,1.0/90,0.0),(-1.0/560,8.0/315,-1.0/5,8.0/5,-205.0/72,8.0/5,-1.0/5,8.0/315,-1.0/560)],
    [(0.0,0.0,-1.0/2,1.0,0.0,-1.0,1.0/2,0.0,0.0),(0.0,1.0/8,-1.0,13.0/8,0.0,-13.0/8,1.0,-1.0/8,0.0),(-7.0/240,3.0/10,-169.0/120,61.0/30,0.0,-61.0/30,169.0/120,-3.0/10,7.0/240),(0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)]
];
/*
    @brief calculate central finite difference of given order and accuracy
    @param: A:StenArray -> A StenArray object
    @param: order:int -> Order of calculation  possible values range [1..3]
    @param: accuracy:int -> Accuracy of calculation possible values [2,4,6]
    @param: step:real -> step value (h or dx)
    @param: axis:int -> Axis along which method is applied
*/
proc central_diff(A:StenArray,order:int(32),accuracy:int(32),step:real(64),axis:int(8)=0,debugFlag:bool=false){
    var extnt_temp = -accuracy/2..accuracy/2;

    var wts:list(real(64));
    
    for j in extnt_temp{
        wts.append(weights[order-1][(accuracy-1)/2][4+j]);
    }
    if(debugFlag){
        writeln("weights = ",wts);
        writeln("Extents = ",extnt_temp);
    }
    var temp = A.derivative(wts,extnt_temp,axis=axis);
    temp.arr /= (step**(order));

    return temp;
}

proc central_diff(A:StenArray,order:int(32),accuracy:int(32),step:real(64),axis:2*int(8)=(0,1)){
    var temp = central_diff(A,order,accuracy,step,axis[0]);
    temp += central_diff(A,order,accuracy,step,axis[1]);
    return temp;
}

const forward_wts = [
    [(-1.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),(-3.0/2,2.0,-1.0/2,0.0,0.0,0.0,0.0,0.0,0.0),(-11.0/6,3.0,-3.0/2,1.0/3,0.0,0.0,0.0,0.0,0.0),(-25.0/12,4.0,-3.0,4.0/3,-1/4.0,0.0,0.0,0.0,0.0),(-137.0/60,5.0,-5.0,10.0/3,-5.0/4,1.0/5,0.0,0.0,0.0),(-49.0/20,6.0,-15.0/2,20.0/3,-15.0/4,6.0/5,-1.0/6,0.0,0.0)],
    [(1.0,-2.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0),(2.0,-5.0,4.0,-1.0,0.0,0.0,0.0,0.0,0.0),(35.0/12,-26.0/3,19.0/2,-14.0/3,11.0/12,0.0,0.0,0.0,0.0),(15.0/4,-77.0/6,107.0/6,-13.0,61.0/12,-5.0/6,0.0,0.0,0.0),(203.0/45,-87.0/5,117.0/4,-254.0/9,33.0/2,-27.0/5,137.0/180,0.0,0.0),(469.0/90,-223.0/10,879.0/20,-949.0/18,41.0,-201.0/10,1019.0/180,-7.0/10,0.0)],
    [(-1.0,3.0,-3.0,1.0,0.0,0.0,0.0,0.0,0.0),(-5.0/2,9.0,-12.0,7.0,-3.0/2,0.0,0.0,0.0,0.0),(-17.0/4,71.0/4,-59.0/2,49.0/2,-41.0/4,7.0/4,0.0,0.0,0.0),(-49.0/8,29.0,-461.0/8,62.0,-307.0/8,13.0,-15.0/8,0.0,0.0),(-967.0/120,638.0/15,-3929.0/40,389.0/3,-2545.0/24,268.0/5,-1849.0/120,29.0/15,0.0),(-801.0/80,349.0/6,-18353.0/120,2391.0/10,-1457.0/6,4891.0/30,-561.0/8,527.0/30,-469.0/240)]
];

/*
    @brief calculate foward finite difference of given order and accuracy
    @param: A:StenArray -> A StenArray object
    @param: order:int -> Order of calculation  possible values range [1..3]
    @param: accuracy:int -> Accuracy of calculation possible values [1..6]
    @param: step:real -> step value (h or dx)
    @param: axis:int -> Axis along which method is applied
*/
proc forward_diff(A:StenArray,order:int(32),accuracy:int(32),step:real(64),axis:int(8)=0,debugFlag=false){
    
    var extnt_temp = 0..(accuracy+order-1);

    var wts:list(real(64));
    
    for j in extnt_temp{
        wts.append(forward_wts[order-1][accuracy-1][j]);
    }
    if(debugFlag){
        writeln("weights = ",wts);
        writeln("Extents = ",extnt_temp);
    }


    var temp = A.derivative(wts,extnt_temp,axis=axis);
    temp.arr /= (step**(order));

    return temp;
}

proc forward_diff2D(A:StenArray,order:int(32),accuracy:int(32),step:real(64),axis:2*int(8)=(0,1)){
    var temp = forward_diff(A,order,accuracy,step,axis[0]);
    temp += forward_diff(A,order,accuracy,step,axis[1]);
    return temp;
}

const backward_wts = [
    [(0.0,0.0,0.0,-1.0,1.0),(0.0,0.0,1.0/2,-2.0,3.0/2)],
    [(0.0,0.0,1.0,-2.0,1.0),(0.0,-1.0,4.0,-5.0,2.0)],
    [(0.0,-1.0,3.0,-3.0,1.0),(3.0/2,-7.0,12.0,-9.0,5.0/2)]
];
/*
    @brief calculate central finite difference of given order and accuracy
    @param: A:StenArray -> An StenArray object
    @param: order:int -> Order of calculation  possible values range [1..3]
    @param: accuracy:int -> Accuracy of calculation possible values [1,2]
    @param: step:real -> step value (h or dx)
    @param: axis:int -> Axis along which method is applied
*/
proc backward_diff(A:StenArray,order:int(32),accuracy:int(32),step:real(64),axis:int(8)=0,debugFlag=false){
    
    var extnt_temp = -(accuracy+order-1)..0;

    var wts:list(real(64));
    
    for j in extnt_temp{
        wts.append(backward_wts[order-1][accuracy-1][4+j]);
    }
    if(debugFlag){
        writeln("weights = ",wts);
        writeln("Extents = ",extnt_temp);
    }


    var temp = A.derivative(wts,extnt_temp,axis=axis);
    temp.arr /= (step**(order));

    return temp;
}

proc backward_diff2D(A:StenArray,order:int(32),accuracy:int(32),step:real(64),axis:2*int(8)=(0,1)){
    var temp = backward_diff(A,order,accuracy,step,axis[0]);
    temp += backward_diff(A,order,accuracy,step,axis[1]);
    return temp;
}


// --------------- Derivative for specified domains (Mixed Derivative)
// Example if on first half we need to perform forward difference and central for rest

proc mixed_derivative(A:StenArray,const scheme:string,const d:domain,const order:int,const accuracy:int,const step:real,const axis:int){
    var temp:StenArray;
    var extnt_temp:range;
    var wts:list(real(64));
    select scheme{
        when "forward" do{
            //TODO: Apply Forward Scheme;
            extnt_temp = 0..(accuracy+order-1);
            for j in extnt_temp{
                wts.append(forward_wts[order-1][accuracy-1][j]);
            }

            writeln("Applying Forward");
        }
        
        when "backward" do{
            //TODO: Apply Backward Scheme;
            extnt_temp = -(accuracy+order-1)..0;
            for j in extnt_temp{
                wts.append(backward_wts[order-1][accuracy-1][4+j]);
            }

            writeln("Applying Backward");
        }

        when "central" do{
            //TODO: Apply Central Scheme;
            extnt_temp = -accuracy/2..accuracy/2;
            for j in extnt_temp{
                wts.append(weights[order-1][(accuracy-1)/2][4+j]);
            }
            
            writeln("Applying Central");
        }
        otherwise
            writeln("Error: Mixed Derivative! Wrong Scheme Name");
    }
    writeln(wts);
    writeln(extnt_temp);
    temp = A.spec_derivative(d,wts,extnt_temp,axis);
    temp.arr[d] /= (step**order);
    return temp;
}