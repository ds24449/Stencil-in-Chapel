use DataArray;
use List;

/*Plan for FD class

private: 
    Primitive Functions

Public:
    apply_boundary_condiditions
    FD_method 
    central_method
    forward_method
    backward_method
    run_fuction ?
*/

class FDSolver{
    // Member variables
    const weights = [
        [(0.0,0.0,0.0,-1.0/2,0.0,1.0/2,0.0,0.0,0.0),(0.0,0.0,1.0/12,-2.0/3,0.0,2.0/3,-1.0/12,0.0,0.0),(0.0,-1.0/60,3.0/20,-3.0/4,0.0,3.0/4,-3.0/20,1.0/60,0.0),(1.0/280,-4.0/105,1.0/5,-4.0/5,0.0,4.0/5,-1.0/5,4.0/105,-1.0/280)],
        [(0.0,0.0,0.0,1.0,-2.0,1.0,0.0,0.0,0.0),(0.0,0.0,-1.0/12,4.0/3,-5.0/2,4.0/3,-1.0/12,0.0,0.0),(0.0,1.0/90,-3.0/20,3.0/2,-49.0/18,3.0/2,-3.0/20,1.0/90,0.0),(-1.0/560,8.0/315,-1.0/5,8.0/5,-205.0/72,8.0/5,-1.0/5,8.0/315,-1.0/560)],
        [(0.0,0.0,-1.0/2,1.0,0.0,-1.0,1.0/2,0.0,0.0),(0.0,1.0/8,-1.0,13.0/8,0.0,-13.0/8,1.0,-1.0/8,0.0),(-7.0/240,3.0/10,-169.0/120,61.0/30,0.0,-61.0/30,169.0/120,-3.0/10,7.0/240),(0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)]
    ];
    const forward_wts = [
        [(-1.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),(-3.0/2,2.0,-1.0/2,0.0,0.0,0.0,0.0,0.0,0.0),(-11.0/6,3.0,-3.0/2,1.0/3,0.0,0.0,0.0,0.0,0.0),(-25.0/12,4.0,-3.0,4.0/3,-1/4.0,0.0,0.0,0.0,0.0),(-137.0/60,5.0,-5.0,10.0/3,-5.0/4,1.0/5,0.0,0.0,0.0),(-49.0/20,6.0,-15.0/2,20.0/3,-15.0/4,6.0/5,-1.0/6,0.0,0.0)],
        [(1.0,-2.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0),(2.0,-5.0,4.0,-1.0,0.0,0.0,0.0,0.0,0.0),(35.0/12,-26.0/3,19.0/2,-14.0/3,11.0/12,0.0,0.0,0.0,0.0),(15.0/4,-77.0/6,107.0/6,-13.0,61.0/12,-5.0/6,0.0,0.0,0.0),(203.0/45,-87.0/5,117.0/4,-254.0/9,33.0/2,-27.0/5,137.0/180,0.0,0.0),(469.0/90,-223.0/10,879.0/20,-949.0/18,41.0,-201.0/10,1019.0/180,-7.0/10,0.0)],
        [(-1.0,3.0,-3.0,1.0,0.0,0.0,0.0,0.0,0.0),(-5.0/2,9.0,-12.0,7.0,-3.0/2,0.0,0.0,0.0,0.0),(-17.0/4,71.0/4,-59.0/2,49.0/2,-41.0/4,7.0/4,0.0,0.0,0.0),(-49.0/8,29.0,-461.0/8,62.0,-307.0/8,13.0,-15.0/8,0.0,0.0),(-967.0/120,638.0/15,-3929.0/40,389.0/3,-2545.0/24,268.0/5,-1849.0/120,29.0/15,0.0),(-801.0/80,349.0/6,-18353.0/120,2391.0/10,-1457.0/6,4891.0/30,-561.0/8,527.0/30,-469.0/240)]
    ];
    const backward_wts = [
        [(0.0,0.0,0.0,-1.0,1.0),(0.0,0.0,1.0/2,-2.0,3.0/2)],
        [(0.0,0.0,1.0,-2.0,1.0),(0.0,-1.0,4.0,-5.0,2.0)],
        [(0.0,-1.0,3.0,-3.0,1.0),(3.0/2,-7.0,12.0,-9.0,5.0/2)]
    ];

    var orig: DataArray; // Data Upon which FD will work
    // TODO: create a const dom on which the derivative will work and then 
    // use orig data to add padding and create boundary conditions 
    const dom: domain;

    proc init(const orig:DataArray){
        this.orig = new owned DataArray(orig.arr,orig.dimensions);
        this.dom = orig.dom;
    }

    // Procedures for Finite Differences 
    // --- Primitive Procedures ---
    proc derivative(const weight,const extent,const axis:int = 0){ 
        if(weight.size != extent.size) then writeln("Weight and Extent length Mis-Match in derivative function");

        var data:DataArray = new owned DataArray(this.orig.arr[this.dom],this.orig.dimensions); // change the domain here

        if(data.dom.rank == 1){
            forall i in data.dom{
                data.arr[i] = 0;
                for (k,j) in zip(weight,extent){
                    data.arr[i] += k*this.orig.arr[i+j]; //TODO: LOOK OUT THESE IFs
                }
            }
        }
        else{
            forall i in data.dom{
                var sum:real = 0.0;

                for (k,j) in zip(weight,extent){
                    var temp = i;
                    temp[axis] += j;
                    sum += (k*this.orig.arr[temp]); //TODO: LOOK OUT FOR THESE IFs
                }
                data.arr[i] = sum;
            }
        }
        //data.arr.updateFluff();

        return data;
    } 
    /*
        @brief Calculate derivative along 2-Dimensions
        @param weight -> Tuple of Tuple of values to be applied as weights to indices of matrix. Must have 2 Tuples for each individual axis.
        @param extent -> ranges of indices to be taken into account while calculating stencil operation. Must have Tuple of ranges.
        @param axis -> A Tuple of integers along which we need to find the derivative.
    */
    proc derivative(const weight,const extent,const axis: range){
        var data:DataArray = new owned DataArray(this.orig.arr[this.dom],this.orig.dimensions);
        data.arr = 0;

        for ax in axis{
            var temp = derivative(weight,extent,ax);
            data += temp; 
        }

        return data;
    }

    proc apply_boundary(const ax:int,left_bc:string,right_bc:string,accuracy=2){
        var old_dom = this.dom;
        
        if(left_bc == "periodic"){
            for i in 1..accuracy{
                if(this.orig.rank == 1){
                    this.orig.arr[this.dom.low-i] = this.orig.arr[this.dom.high+1-i];
                    this.orig.arr[this.dom.high+i] = this.orig.arr[i];
                }else if(this.orig.rank == 2){
                    var n = old_dom.high[ax];
                    var left_b:domain(2);
                    var left_orig:domain(2);

                    var right_b:domain(2);
                    var right_orig:domain(2);

                    if(ax == 0){
                        left_b = {1-i..1-i,1..n};
                        left_orig = {i..i,1..n};

                        right_b = {n+i..n+i,1..n};
                        right_orig = {n-i+1..n-i+1,1..n};
                    }else{
                        left_b = {1..n,1-i..1-i}; // These values are to be replaced by right_orig
                        left_orig = {1..n,i..i}; // These values will replace right_b

                        right_b = {1..n,n+i..n+i};
                        right_orig = {1..n,n-i+1..n-i+1};
                    }
                    this.orig.arr[left_b] = this.orig.arr[right_orig];
                    this.orig.arr[right_b] = this.orig.arr[left_orig];
                }
            }
        }
    }

    // --- High Level Procedures ---

    proc apply_boundary(const dict,accuracy = 2){ //TODO: Take an Associative Array {co-ordinate: bounds type} 
        // X co-ordinate {'x' => "periodic"};
        this.orig.dom = this.orig.dom.expand(accuracy);
        for d in dict.domain{
            var axis:int;
            if(dict.domain.idxType == string){
                for (i,j) in zip(0..this.orig.dimensions.rank,this.orig.dimensions){
                    if(d == j){
                        axis = i;
                        break;
                    }
                }
            }else{
                axis = d;
            }

            if(dict[d].type == 2*string){
                var left_bc = dict[d][0];
                var right_bc = dict[d][1];
                apply_boundary(axis,left_bc,right_bc,accuracy = 2);
            }
            else{
                var bc = dict[d];
                apply_boundary(axis,bc,bc,accuracy = 2);
            }
        }
    }

    /*
        @brief calculate central finite difference of given order and accuracy
        @param: A:DataArray -> A DataArray object
        @param: order:int -> Order of calculation  possible values range [1..3]
        @param: accuracy:int -> Accuracy of calculation possible values [2,4,6]
        @param: step:real -> step value (h or dx)
        @param: axis:int -> Axis along which method is applied
    */
    proc Finite_Difference(scheme = "central",order:int(32) = 1,accuracy:int(32) = 2,step:real(64),axis:int = 0,debugFlag:bool=false){
        select scheme{
            when "forward" do{
                return forward_diff(order,accuracy,step,axis);
            }
            when "backward" do{
                return backward_diff(order,accuracy,step,axis);
            }
            when "central" do{
                return central_diff(order,accuracy,step,axis);
            }

            otherwise{
                writeln("Error: Wrong Scheme Name");
                return new DataArray(this.orig.arr,this.orig.dimensions);
            }
        }
    }

    proc Finite_Difference(scheme = "central",order:int(32) = 1,accuracy:int(32) = 2,step:real(64),axis:range = 0..0,debugFlag:bool=false):DataArray{
        //TODO: Change this from 2D to work on range of axis
        select scheme{
            when "forward" do{
                return forward_diff(order,accuracy,step,axis);
            }
            when "backward" do{
                return backward_diff(order,accuracy,step,axis);
            }
            when "central" do{
                return central_diff(order,accuracy,step,axis);
            }
            otherwise{
                writeln("Error: Wrong Scheme Name");
                return new DataArray(this.orig.arr,this.orig.dimensions);
            }
        }
    }

    proc central_diff(order:int(32),accuracy:int(32),step:real(64),axis:int=0,debugFlag:bool=false){
        var extnt_temp = -accuracy/2..accuracy/2;

        var wts:list(real(64));
    
        for j in extnt_temp{
            wts.append(weights[order-1][(accuracy-1)/2][4+j]);
        }
        if(debugFlag){
            writeln("weights = ",wts);
            writeln("Extents = ",extnt_temp);
        }
        var temp = this.derivative(wts,extnt_temp,axis=axis);
        temp.arr /= (step**(order));

        return temp;
    }

    proc central_diff(order:int(32),accuracy:int(32),step:real(64),axis:range = 0..0,debugFlag:bool = false){
        //TODO: Change this from 2D to work on range of axis
        var extnt_temp = -accuracy/2..accuracy/2;

        var wts:list(real(64));
    
        for j in extnt_temp{
            wts.append(weights[order-1][(accuracy-1)/2][4+j]);
        }
        if(debugFlag){
            writeln("weights = ",wts);
            writeln("Extents = ",extnt_temp);
        }
        var temp = this.derivative(wts,extnt_temp,axis=axis);
        temp.arr /= (step**(order));

        return temp;
    }

    /*
        @brief calculate foward finite difference of given order and accuracy
        @param: A:DataArray -> A DataArray object
        @param: order:int -> Order of calculation  possible values range [1..3]
        @param: accuracy:int -> Accuracy of calculation possible values [1..6]
        @param: step:real -> step value (h or dx)
        @param: axis:int -> Axis along which method is applied
    */
    proc forward_diff(order:int(32),accuracy:int(32),step:real(64),axis:int=0,debugFlag=false){
    
        var extnt_temp = 0..(accuracy+order-1);
        var wts:list(real(64));
    
        for j in extnt_temp{
            wts.append(forward_wts[order-1][accuracy-1][j]);
        }
        if(debugFlag){
            writeln("weights = ",wts);
            writeln("Extents = ",extnt_temp);
        }

        var temp = this.derivative(wts,extnt_temp,axis=axis);
        temp.arr /= (step**(order));

        return temp;
    }

    proc forward_diff(order:int(32),accuracy:int(32),step:real(64),axis:range = 0..0){
        //TODO: Change this from 2D to work on range of axis
        var extnt_temp = 0..(accuracy+order-1);
        var wts:list(real(64));
    
        for j in extnt_temp{
            wts.append(forward_wts[order-1][accuracy-1][j]);
        }
        // if(debugFlag){
        //     writeln("weights = ",wts);
        //     writeln("Extents = ",extnt_temp);
        // }

        var temp = this.derivative(wts,extnt_temp,axis=axis);
        temp.arr /= (step**(order));

        return temp;
    }

    /*
        @brief calculate central finite difference of given order and accuracy
        @param: A:DataArray -> An DataArray object
        @param: order:int -> Order of calculation  possible values range [1..3]
        @param: accuracy:int -> Accuracy of calculation possible values [1,2]
        @param: step:real -> step value (h or dx)
        @param: axis:int -> Axis along which method is applied
    */
    proc backward_diff(order:int(32),accuracy:int(32),step:real(64),axis:int=0,debugFlag=false){

        var extnt_temp = -(accuracy+order-1)..0;
        var wts:list(real(64));
        for j in extnt_temp{
            wts.append(backward_wts[order-1][accuracy-1][4+j]);
        }

        if(debugFlag){
            writeln("weights = ",wts);
            writeln("Extents = ",extnt_temp);
        }


        var temp = this.derivative(wts,extnt_temp,axis=axis);
        temp.arr /= (step**(order));

        return temp;
    }

    proc backward_diff(order:int(32),accuracy:int(32),step:real(64),axis:range = 0..0){
        //TODO: Change this from 2D to work on range of axis

        var extnt_temp = -(accuracy+order-1)..0;
        var wts:list(real(64));
        for j in extnt_temp{
            wts.append(backward_wts[order-1][accuracy-1][4+j]);
        }

        var temp = this.derivative(wts,extnt_temp,axis);
        return temp;
    }

}