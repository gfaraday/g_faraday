import 'package:g_json/g_json.dart';

enum SwiftCodeType { protocol, enmu, impl }

List<String> generateSwift(List<JSON> methods, SwiftCodeType type,
    {String identifier}) {
  final result = <String>[];
  for (final method in methods) {
    final name = method['name'].stringValue;
    final args = method['arguments']
        .listValue
        .map((j) =>
            "_ ${j['name'].stringValue}: ${j['type'].stringValue}${j['isRequired'].booleanValue ? '' : '?'}")
        .join(', ')
        .replaceDartTypeToSwift;
    switch (type) {
      case SwiftCodeType.protocol:
        result.add('\n  ' +
            (method['comments'].string?.replaceAll('\n', '\n  ') ??
                '/// NO COMMENTS') +
            '\n  func $name($args) -> Any?');
        break;
      case SwiftCodeType.enmu:
        result.add('\n  ' +
            (method['comments'].string?.replaceAll('\n', '\n  ') ??
                '// NO COMMENTS') +
            '\n  case $name($args)');
        break;
      case SwiftCodeType.impl:
        final lets =
            method['arguments'].listValue.map((j) => j.getter()).join('\n');
        result.add('''    if (name == "$identifier#$name") {
$lets
      // invoke $name
      completions($name(${method['arguments'].listValue.map((j) => j.name).join(', ')}))
      return true
    }
        ''');
        break;
    }
  }
  return result;
}

List<String> generateKotlin(List<JSON> methods, String category) {
  return [];
}

List<String> generateImpl(List<JSON> methods) {
  return [];
}

extension JSONArguments on JSON {
  String get name => this['name'].stringValue;
  String get argumentType => this['type'].stringValue;
  bool get isRequired => this['isRequired'].booleanValue;

  String getter() {
    final let =
        'let $name = args?["$name"] as? $argumentType'.replaceDartTypeToSwift;
    if (isRequired) {
      return '''
      guard $let else {
        fatalError("argument: $name not valid")
      }
      ''';
    }
    return '''
      $let ''';
  }
}

extension StringFaraday on String {
  String get replaceDartTypeToSwift => replaceAll('List', 'Array')
      .replaceAll('Map', 'Dictionary')
      .replaceAll('bool', 'Bool')
      .replaceAll('int', 'Int')
      .replaceAll('float', 'Float')
      .replaceAll('double', 'Double')
      .replaceAll('num', 'Double')
      .replaceAll('null', 'Any?');
}
