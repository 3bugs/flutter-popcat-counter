class Counter {
  int _value;

  Counter([this._value = 0]); // optional positional parameter _value

  int get value => _value; // getter

  void updateValue(int diff) {
    // disable count to negative numbers
    if (_value + diff >= 0) {
      _value += diff;
    }
  }

  void resetValue() {
    _value = 0;
  }
}
