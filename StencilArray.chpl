use StencilDist;
class StenArray{
    // Class Supports N-d Arrays
    var Dom: domain;
    var ProblemSpace: domain;
    var arr: [ProblemSpace] real;
    var fluff_vals = (0,0,0);
    /*
        Initialize The  StenArray Object
        @param: tupleDims-> tuple of dimensions in order (x,y,z)
        @param: boundaryWidth-> Amount of padding to be treated as Boundary 
        @param: fluff[dim] -> Fluff value. Dim = [X | Y | Z]
    */
    proc init(tupleDims,boundaryWidth:int = 1,fluffX = 1,fluffY=1,fluffZ = 1){
        if(tupleDims.size == 1) then {
            this.Dom = {1..tupleDims(0)};
            this.ProblemSpace = Dom dmapped Stencil(Dom.expand(boundaryWidth-1),fluff=(fluffX,));
            this.fluff_vals = (fluffX,fluffY,0);
        }
        else if(tupleDims.size == 2) then {
            var (x,y) = tupleDims;
            this.Dom = {1..#x,1..#y};
            this.ProblemSpace = Dom dmapped Stencil(Dom.expand(boundaryWidth-1),fluff=(fluffX,fluffY));
            this.fluff_vals = (fluffX,fluffY,0);
        }else{
            var (x,y,z) = tupleDims;
            this.Dom = {1..#x,1..#y,1..#z};
            this.ProblemSpace = Dom dmapped Stencil(Dom.expand(boundaryWidth-1),fluff=(fluffX,fluffY,fluffZ));
            this.fluff_vals = (fluffX,fluffY,fluffZ);
        }
    }
    /*
        Initialize a StenArray Object with N-Dimensions
        @param: nDomain-> A Rectangular Domain for Nd array
    */
    proc init(nDomain: domain,fluff_val=1,boundaryWidth:int = 1){

        var temp: nDomain.rank*int;
        for i in temp do i=fluff_val;
        this.Dom = nDomain;
        this.ProblemSpace = Dom dmapped Stencil(Dom.expand(boundaryWidth-1),fluff=temp);
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
        // Check if Number of Elemets in Weight and Extent are same or not
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
        // Do this in data parallel manner
        for i in this.ProblemSpace{
            var sum=0.0;
            coforall taskNo in 0..1 with (+ reduce sum){
                for (k,j) in zip(weight[taskNo],extent[taskNo]){
                    if(!(taskNo == 0 && j==0)){ 
                        var temp = i;
                        temp[axis[taskNo]] += j;
                        sum += k*this.arr[temp];
                    }
                }
            }
            res.arr[i] += sum;
        }
        res.arr.updateFluff();
        return res;
    }
}