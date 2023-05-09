import 'dart:async';

class RecordFileNum {
  final String prefix;
  final String devider;
  final _valueController = StreamController<int>();
  Stream<int> get value => _valueController.stream;

  int _number = 1;

  void increment() {
    _number++;
    _valueController.sink.add(_number);
  }

  void decrement() {
    _number--;
    _valueController.sink.add(_number);
  }

  void dispose() {
    _valueController.close();
  }

  RecordFileNum({
    String? prefix,
    this.devider = '-T', 
    }):prefix = prefix ?? today;
  
  // a function to get the date of today
  // to be used as the defualt prefix of the file name
  static String get today {
    var now = DateTime.now();
    var year = now.year.toString().substring(2);
    var month = now.month.toString().padLeft(2, '0');
    var day = now.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

}

var a = RecordFileNum();
var x = a.prefix;
var y = a.devider;
var z = a.value;
var b = a.increment;
var c = a.decrement;