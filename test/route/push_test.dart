// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   const MethodChannel channel = MethodChannel('g_faraday');

//   TestWidgetsFlutterBinding.ensureInitialized();

//   setUp(() {
//     channel.setMockMethodCallHandler((MethodCall methodCall) async {
//       if (methodCall.method == 'pushNativePage') {
//         return methodCall.arguments;
//       }
//       return null;
//     });
//   });

//   tearDown(() {
//     channel.setMockMethodCallHandler(null);
//   });

//   test('pushNativePage', () async {
//     expect(Faraday);
//   });
// }
