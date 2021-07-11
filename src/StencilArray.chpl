// Obsolete

use StencilDist;
class StenArray{
    var Dom: domain;
    var ProblemSpace: domain;
    var arr: [ProblemSpace] real;
    var fluff_vals = (0,0,0);
    /*
        Initialize The  StenArray Object
        @param: tupleDims-> tuple of dimensions in order (x,y,z)
        @param: padding-> Amount of padding
        @param: fluff[dim] -> Fluff value. Dim = [X | Y | Z]
    */
    proc init(tupleDims,padding:int = 1,fluffX:int = 1,fluffY:int = 1,fluffZ:int = 1){
        if(tupleDims.size == 1) then {
            this.Dom = {1..tupleDims(0)};
            this.ProblemSpace = Dom.expand(padding) dmapped Stencil(Dom.expand(padding),fluff=(fluffX,));
            this.fluff_vals = (fluffX,0,0);
        }
        else if(tupleDims.size == 2) then {
            var (x,y) = tupleDims;
            this.Dom = {1..#x,1..#y};
            this.ProblemSpace = Dom.expand(padding) dmapped Stencil(Dom.expand(padding),fluff=(fluffX,fluffY));
            this.fluff_vals = (fluffX,fluffY,0);
        }else{
            var (x,y,z) = tupleDims;
            this.Dom = {1..#x,1..#y,1..#z};
            this.ProblemSpace = Dom.expand(padding) dmapped Stencil(Dom.expand(padding),fluff=(fluffX,fluffY,fluffZ));
            this.fluff_vals = (fluffX,fluffY,fluffZ);
        }
    }
    /*
        Initialize a StenArray Object with N-Dimensions
        @param: nDomain-> A Rectangular Domain for Nd array
    */
    proc init(nDomain: domain,fluff_val:int = 1,padding:int = 1){
        var temp: nDomain.rank*int;
        for i in temp do i=fluff_val;
        this.Dom = nDomain;
        this.ProblemSpace = Dom.expand(padding) dmapped Stencil(Dom.expand(padding),fluff=temp);
    }
    /*
        Copy Constructor
        @param a-> An Instance of the StenArray Class
    */
    proc init(const a:StenArray,copyVal:bool = false){
        this.Dom = a.Dom;
        this.ProblemSpace = a.ProblemSpace;
        if(copyVal) then this.arr = a.arr;
        else this.arr = 0;
    }

    /*
        @brief calculate derivative along axis
        @param weight -> Tuple of values to be applied as weights to indices of matrix
        @param extent -> range of indices to be taken into account while calculating stencil operation
        @param axis -> An integer along which we need to find the derivative
    */
    proc derivative(const weight,const extent,const axis:int = 0){ 
        if(weight.size != extent.size) then writeln("Weight and Extent length Mis-Match in derivative function");
        var res:StenArray = new StenArray(this,false);
        if(this.ProblemSpace.rank == 1){
            forall i in this.Dom{
                for (k,j) in zip(weight,extent){
                    res.arr[i] += k*this.arr[i+j];
                }
            }
        }else{
            forall i in this.Dom{
                var sum:real = 0.0;
                for (k,j) in zip(weight,extent){
                    var temp = i;
                    temp[axis] += j;
                    sum += (k*this.arr[temp]);
                }
                res.arr[i] = sum;
            }
        }
        //res.arr.updateFluff();
        return res;
    }

    
    /*
        @brief Calculate derivative along 2-Dimensions
        @param weight -> Tuple of Tuple of values to be applied as weights to indices of matrix. Must have 2 Tuples for each individual axis.
        @param extent -> ranges of indices to be taken into account while calculating stencil operation. Must have Tuple of ranges.
        @param axis -> A Tuple of integers along which we need to find the derivative.
    */
    proc derivative2D(const weight,const extent,const axis: 2*int){
        var res:StenArray = new StenArray(this,false);
        // Do this in data parallel manner
        var temp1,temp2:StenArray;
        temp1 = new StenArray(this,false);
        temp2 = new StenArray(this,false);
        coforall taskNo in 0..1 with (ref temp1,ref temp2){
            if(taskNo == 0){
                temp1 = derivative(weight[taskNo],extent[taskNo],axis[taskNo]);
            }else{
                temp2 = derivative(weight[taskNo],extent[taskNo],axis[taskNo]);
            }
        }
        res.arr = temp1.arr + temp2.arr;
        res.arr.updateFluff();
        return res;
    }


    /*
        This Function Takes the domain and calculates value for specified domain
    */
    proc spec_derivative(const d:domain,const weight,const extent,const axis){
        
        // TODO: Make These Try..Catch blocks. 
        if(weight.size != extent.size) then writeln("Weight and Extent length Mis-Match in derivative function");
        if(d.rank != this.ProblemSpace.rank) then writeln("Raise Error Here! Rank MisMatch");

        var res:StenArray = new StenArray(this,false);
        if(this.ProblemSpace.rank == 1){
            forall i in d{
                for (k,j) in zip(weight,extent){
                    res.arr[i] += k*this.arr[i+j];
                }
            }
        }else{
            forall i in d{
                var sum:real = 0.0;
                for (k,j) in zip(weight,extent){
                    var temp = i;
                    temp[axis] += j;
                    // writeln(this.arr[temp]);
                    sum += (k*this.arr[temp]);
                    // writeln("[INTERNAL DEBUG - VARIABLES]");
                    // writeln(" temp = ",temp);
                    // writeln(" (i,j,k) = ( ",i," ,",j," ,",k,")");
                    // writeln(" calculation = ",k*this.arr[temp]);
                    // writeln(" sum = ",sum);
                }
                res.arr[i] = sum;
            }
        }

        //res.arr.updateFluff();
        // writeln("-------------------[INTERNAL DEBUG]-------------------");
        // writeln(res.arr);
        // writeln("-------------------[INTERNAL DEBUG]-------------------");
        return res.arr[d]; // Returning Value for the domain d;
    }


    operator +(lhs:StenArray,rhs:StenArray){
        var temp = new StenArray(lhs,false);
        try{
            if((lhs.Dom.rank == rhs.Dom.rank) && (lhs.Dom.dims() == rhs.Dom.dims())){
                temp.arr = lhs.arr+rhs.arr;
                return temp;
            }else{
                throw new Error("Rank or Domain MisMatch Found");
            }
        }catch e{
            writeln("Error Raised While Adding StenArray ",e);
            return temp;
        }
    }

    operator -(lhs:StenArray,rhs:StenArray){
        var temp = new StenArray(lhs,false);
        try{
            if((lhs.Dom.rank == rhs.Dom.rank) && (lhs.Dom.dims() == rhs.Dom.dims())){
                temp.arr = lhs.arr-rhs.arr;
                return temp;
            }else{
                throw new Error("Rank or Domain MisMatch Found");
            }
        }catch e{
            writeln("Error Raised While Subtracting StenArray ",e);
            return temp;
        }
    }

    proc dims() const {
        return this.Dom.dims();
    }

    proc dim(idx: int) const{
        return this.Dom.dim(idx);
    }
}

proc Apply_Bounds(ref A:StenArray,boundType:string){
    if(boundType.toLower() == "periodic"){
        if(A.ProblemSpace.rank == 1){
            var diff = A.ProblemSpace.high - A.Dom.high;
            var n = A.Dom.high;
            forall i in 1..diff{
                A.arr[1-i] = A.arr[n+1 - i];
                A.arr[n+i] = A.arr[i]; 
            }
        }

        if(A.ProblemSpace.rank == 2){
            var diff = A.ProblemSpace.high[0] - A.Dom.high[0]; //Padding
            var n = A.Dom.high[0]; // because it is rectangular domain {1..n,1..n}
            for i in 1..diff{
                var left_replace:domain = {1..n,1-i..1-i}; // These values are to be replaced by right_orig
                var left_orig:domain = {1..n,i..i}; // These values will replace right_replace

                var right_replace:domain = {1..n,n+i..n+i};
                var right_orig:domain = {1..n,n-i+1..n-i+1};

                var top_replace:domain = {1-i..1-i,1..n};
                var top_orig:domain = {i..i,1..n};

                var bottom_replace:domain = {n+i..n+i,1..n};
                var bottom_orig:domain = {n-i+1..n-i+1,1..n};

                begin A.arr[left_replace] = A.arr[right_orig];
                begin A.arr[right_replace] = A.arr[left_orig];
                begin A.arr[top_replace] = A.arr[bottom_orig];
                begin A.arr[bottom_replace] = A.arr[top_orig];
            }
        }
    }
}
