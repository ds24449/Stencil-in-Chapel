use StencilDist;
class StenArray{
    var Dom: domain;
    var ProblemSpace: domain;
    var arr: [ProblemSpace] real;
    var fluff_vals = (0,0,0);
    /*
        Initialize The  StenArray Object
        @param: tupleDims-> tuple of dimensions in order (x,y,z)
        @param: padding-> Amount of padding to be added 
        @param: fluff[dim] -> Fluff value. Dim = [X | Y | Z]
    */
    proc init(tupleDims,padding:int = 1,fluffX = 1,fluffY=1,fluffZ = 1){
        if(tupleDims.size == 1) then {
            this.Dom = {1..tupleDims(0)};
            this.ProblemSpace = Dom.expand(padding) dmapped Stencil(Dom.expand(padding),fluff=(fluffX,));
            this.fluff_vals = (fluffX,fluffY,0);
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
    proc init(nDomain: domain,fluff_val=1,padding:int = 1){

        var temp: nDomain.rank*int;
        for i in temp do i=fluff_val;
        this.Dom = nDomain;
        this.ProblemSpace = Dom.expand(padding) dmapped Stencil(Dom.expand(padding),fluff=temp);
    }
    /*
        Copy Constructor
        @param a-> An Instance of the StenArray Class
    */
    proc init(const a:StenArray,copyVal = true){
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
    proc derivative(const weight,const extent,const axis:int=0){ 
        if(weight.size != extent.size) then writeln("Weight and Extent length Mis-Match in derivative function");
        var res:StenArray = new StenArray(this);
        if(this.ProblemSpace.rank == 1){
            forall i in this.ProblemSpace{
                for (k,j) in zip(weight,extent){
                    res.arr[i] += k*this.arr[i+j];
                }
            }
        }else{
            forall i in this.ProblemSpace{
                var sum = 0.0;
                for (k,j) in zip(weight,extent){
                    var temp = i;
                    temp[axis] += j;
                    sum += k*this.arr[temp];
                }
                res.arr[i] = sum;
            }
        }
        res.arr.updateFluff();
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
            writeln("Error Raised While Adding StenArray's ",e);
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
            writeln("Error Raised While Adding StenArray's ",e);
            return temp;
        }
    }

    proc dims() const {
        return this.Dom;
    }

    proc dim(idx: int) const{
        return this.Dom(idx);
    }
}

proc Apply_Bounds(A:StenArray,boundType:string){
    if(boundType.toLower() == "periodic"){
        if(A.ProblemSpace.rank>1){
            for i in 0..<A.ProblemSpace.rank{
                for j in A.Dom{
                    var k = j;
                    var l = j;
                    l[i] = A.ProblemSpace.dim(i).low;
                    k[i] = A.ProblemSpace.dim(i).high;
                    var new_j_1 = j;
                    var new_j_2 = j;
                    new_j_1[i] = A.Dom.dim(i).high;
                    new_j_2[i] = A.Dom.dim(i).low;
                    A.arr[l] = A.arr[new_j_1];
                    A.arr[k] = A.arr[new_j_2];
                }
            }
        }else{
            for j in A.Dom{
                var k = j;
                var l = j;
                l = A.ProblemSpace.low;
                k = A.ProblemSpace.high;
                var new_j_1 = j;
                var new_j_2 = j;
                new_j_1 = A.Dom.high;
                new_j_2 = A.Dom.low;
                A.arr[l] = A.arr[new_j_1];
                A.arr[k] = A.arr[new_j_2];
            }
        }
    }
}