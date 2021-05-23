// import 'dart:async';

// void main() {
//   var tunnel = StreamController<int>();
//   var tunnel2 = tunnel;
//   tunnel.sink.add(193);
//   print('i just added to sink');
//   Timer(Duration(seconds: 1),(){
//   tunnel.stream.listen((value) {print(value); });
//   });

//   tunnel2.sink.add(1934);
//   tunnel.stream.listen((value) {print(value); });
// }