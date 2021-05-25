use StencilArray;
use List;

const weights = [
    [(0.0,0.0,0.0,-1.0/2,0.0,1.0/2,0.0,0.0,0.0),(0.0,0.0,1.0/12,-2.0/3,0.0,2.0/3,-1.0/12,0.0,0.0),(0.0,-1.0/60,3.0/20,-3.0/4,0.0,3.0/4,-3.0/20,1.0/60,0.0),(1.0/280,-4.0/105,1.0/5,-4.0/5,0.0,4.0/5,-1.0/5,4.0/105,-1.0/280)],
    [(0.0,0.0,0.0,1.0,-2.0,1.0,0.0,0.0,0.0),(0.0,0.0,-1.0/12,4.0/3,-5.0/2,4.0/3,-1.0/12,0.0,0.0),(0.0,1.0/90,-3.0/20,3.0/2,-49.0/18,3.0/2,-3.0/20,1.0/90,0.0),(-1.0/560,8.0/315,-1.0/5,8.0/5,-205.0/72,8.0/5,-1.0/5,8.0/315,-1.0/560)],
    [(0.0,0.0,-1.0/2,1.0,0.0,-1.0,1.0/2,0.0,0.0),(0.0,1.0/8,-1.0,13.0/8,0.0,-13.0/8,1.0,-1.0/8,0.0),(-7.0/240,3.0/10,-169.0/120,61.0/30,0.0,-61.0/30,169.0/120,-3.0/10,7.0/240),(0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)]
];

proc central_diff(A:StenArray,order:int(32),accuracy:int(32),step:real(64),axis=0){
    var extnt_temp = -accuracy/2..accuracy/2;

    var wts:list(real(64));
    
    for j in extnt_temp{
        wts.append(weights[order-1][(accuracy-1)/2][4+j]);
    }
    var temp = A.derivative(wts,extnt_temp,axis=axis);
    temp.arr /= (step**(order));

    return temp;
}

proc central_diff(A:StenArray,order:int(32),accuracy:int(32),step:real(64),axis=(0,1)){
    var temp = central_diff(A,order,accuracy,step,axis[0]);
    temp += central_diff(A,order,accuracy,step,axis[1]);
    return temp;
}

