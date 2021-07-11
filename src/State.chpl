module State {
    use DataArray;
    use Map;

    class State {
        var time: int;
        var data_map: map(string, shared AbstractDataArray);

        proc add(property: string, array: shared DataArray) {
            this.data_map.add(property, array);
        }

        proc getValue(property: string) {
            return this.data_map.getValue(property);
        }
    }
}