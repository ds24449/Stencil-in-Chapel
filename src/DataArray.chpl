module DataArray {
    enum DType {Int64, Real64, Bool, String, Undefined};

    proc toDType(type t) {
        select t {
            when int do
                return DType.Int64;
            when real do 
                return DType.Real64;
            when bool do 
                return DType.Bool;
            when string do 
                return DType.String;
            otherwise
                return DType.Undefined;
        }
    }
    
    class AbstractDataArray {
        var d_type: DType;
        const rank: int;

        proc init(type d_type, rank: int) {
            this.d_type = toDType(d_type);
            this.rank = rank;
        }

        proc _add(lhs): owned AbstractDataArray {
            halt("Pure virtual method");
        }

        proc add(rhs: borrowed AbstractDataArray): owned AbstractDataArray {
            halt("Pure virtual method");
        }

        proc _subtract(lhs): owned AbstractDataArray {
            halt("Pure virtual method");
        }

        proc subtract(rhs: borrowed AbstractDataArray): owned AbstractDataArray {
            halt("Pure virtual method");
        }

        proc _eq(lhs): bool {
            halt("Pure virtual method");
        }

        proc eq(rhs: borrowed AbstractDataArray): bool {
            halt("Pure virtual method");
        }

        proc convertTo(type to_convert): owned AbstractDataArray {
            halt("Pure virtual method");
        }
    }

    class DataArray: AbstractDataArray {
        type eltType;       //Super Init
        param rank: int;    //Super Init
        param stridable: bool;

        var dom: domain(rank, stridable = stridable);
        var arr: [dom] eltType;
        var dimensions: domain(string);

        proc init(type eltType, size: domain, dimensions: domain(string)) where isDefaultInitializable(eltType) {
            super.init(eltType, size.rank);
            this.eltType = eltType;
            this.rank = size.rank;
            this.stridable = size.stridable;
            this.dom = size;

            var arr: [size] eltType;
            this.arr = arr;

            this.dimensions = dimensions;
        }

        proc init(size: domain, dimensions: domain(string), in default_value) where isDefaultInitializable(default_value) {
            super.init(default_value.type, size.rank);
            this.eltType = default_value.type;
            this.rank = size.rank;
            this.stridable = size.stridable;
            this.dom = size;
            
            var arr: [size] eltType = default_value;
            this.arr = arr;

            this.dimensions = dimensions;
        }

        proc init(in arr, dimensions: domain(string)) {
            super.init(arr.eltType, arr.domain.rank);
            this.eltType = arr.eltType;
            this.rank = arr.domain.rank;
            this.stridable = arr.domain.stridable;

            this.dom = arr.domain;
            this.arr = arr;

            this.dimensions = dimensions;
        }

        override proc _add(lhs: borrowed DataArray): owned AbstractDataArray where this.rank == lhs.rank && isOperable(lhs, this) {
            var rhs: borrowed DataArray = this;
            var arr = lhs.arr + rhs.arr;
            return new owned DataArray(arr, lhs.dimensions);
        }

        override proc add(rhs: borrowed AbstractDataArray): owned AbstractDataArray {
            return rhs._add(this);
        }

        override proc _subtract(lhs: borrowed DataArray): owned AbstractDataArray where this.rank == lhs.rank && isOperable(lhs, this) {
            var rhs: borrowed DataArray = this;
            var arr = lhs.arr - rhs.arr;
            return new owned DataArray(arr, lhs.dimensions);
        }

        override proc subtract(rhs: borrowed AbstractDataArray): owned AbstractDataArray {
            return rhs._subtract(this);
        }

        override proc _eq(lhs: borrowed DataArray): bool where isOperable(lhs, this) {
            var rhs: borrowed DataArray = this;

            if lhs.arr._value == rhs.arr._value then
                return true;

            if lhs.rank != rhs.rank then
                return false;

            if lhs.dom.size: uint != rhs.dom.size: uint then
                return false;

            if isRectangularDom(lhs.dom) && isRectangularDom(rhs.dom) {
                for d in 0..#rhs.rank do
                    if rhs.dom.dim(d).size: uint != lhs.dom.dim(d).size: uint then
                        return false;
            }

            var ret = true;
            forall (l, r) in zip(lhs.arr, rhs.arr) with (&& reduce ret) do
                ret &&= (l == r);
            return ret;
        }

        override proc eq(rhs: borrowed AbstractDataArray): bool {
            return rhs._eq(this);
        }
    }

    proc isOperable(lhs: borrowed DataArray, rhs: borrowed DataArray) param {
        if !isPrimitive(lhs.eltType) && !isPrimitive(rhs.eltType) {
            return lhs.arr[lhs.dom.alignedLow].dims(rhs.arr[rhs.dom.alignedLow]);
        }
        return isCoercible(lhs.eltType, rhs.eltType);
    }

    operator +(lhs: borrowed AbstractDataArray, rhs: borrowed AbstractDataArray): owned AbstractDataArray {
        return lhs.add(rhs);
    }

    operator +(lhs: DataArray, rhs: DataArray): owned DataArray {
        var sum_ = new DataArray(lhs.arr+rhs.arr,lhs.dimensions);
        return sum_;
    }

    operator -(lhs: borrowed AbstractDataArray, rhs: borrowed AbstractDataArray): owned AbstractDataArray {
        return lhs.subtract(rhs);
    }

    operator ==(lhs: borrowed AbstractDataArray, rhs: borrowed AbstractDataArray): bool {
        return lhs.eq(rhs);
    } 

    operator !=(lhs: borrowed AbstractDataArray, rhs: borrowed AbstractDataArray): bool {
        return !(lhs == rhs);
    }    
}
