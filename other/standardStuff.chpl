proc Std5PointStencil(res:StenArray,const weight:real = 1){
    /*
        Standard 5 Point Stencil Implementation
    */
    const stencil5pts:domain = ((-1,0),(0,-1),(0,0),(0,1),(1,0));
    if(this.ProblemSpace.shape.size == 2) then {
        forall i in this.Dom do{
            res.arr[i] = (+ reduce [j in stencil5pts] weight*this.arr[i+j]);
        }
    }else{
        forall (i,j,k) in this.Dom do{
            res.arr(i,j,k) = (+ reduce [(l,m) in stencil5pts] weight*this.arr(i+l,j+m,k));
        }
    }
}

proc Std9PointStencil(res:StenArray){
    /*
        Standard 9 Point Stencil Implementation
    */
    const stencil9pts = {-1..1,-1..1};
    if(this.ProblemSpace.shape.size == 2) then {
        forall i in this.Dom do{
            res.arr[i] = (+ reduce [j in stencil9pts] this.arr[i+j]);
        }
    }else{
        forall (i,j,k) in this.Dom do{
            res.arr(i,j,k) = (+ reduce [(l,m) in stencil9pts] this.arr(i+l,j+m,k));
        }
    }
}

proc Std27PointStencil(res:StenArray){
    /*
        Standard 27 Point Stencil Implementation
    */
    const stencil27pts = {-1..1,-1..1,-1..1};
    if(this.ProblemSpace.shape.size == 2) then {
         writeln("Not Supported for 2-D array");
    }else{
        forall i in this.Dom do{
            res.arr[i] = (+ reduce [j in stencil27pts] this.arr[i+j]);
        }
    }
}