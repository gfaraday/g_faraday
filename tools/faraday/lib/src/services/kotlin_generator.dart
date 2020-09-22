import 'package:g_json/g_json.dart';
import 'package:recase/recase.dart';

enum KotlinCodeType { interface, sealed, impl }

List<String> generateKotlin(List<JSON> methods, KotlinCodeType type,
    {String identifier}) {
  final result = <String>[];
  for (final method in methods) {
    final name = method['name'].stringValue;
    final args = method['arguments'].listValue;

    switch (type) {
      case KotlinCodeType.interface:
        final parameters = args
            .map((dynamic j) =>
                '${j.name}: ${j['type'].stringValue}${j.isRequired ? '' : '?'}')
            .join(', ');
        result.add('    fun $name($parameters): Any?'.replaceDartTypeToKotlin);
        break;
      case KotlinCodeType.sealed:
        final map =
            args.map((dynamic j) => '"${j.name}" to ${j.name}').join(', ');
        final properties = args
            .map((dynamic j) => 'val ${j.name}: ${j['type'].stringValue}')
            .join(', ');
        final parameters = map.isEmpty ? 'null' : 'hashMapOf($map)';
        var comments =
            (method['comments'].string?.replaceAll('\n', '\n    ') ?? '');
        if (comments.isNotEmpty) comments = '    ' + comments + '\n';
        if (properties.isEmpty) {
          result.add(comments +
              '    object ${name.pascalCase}: FlutterRoute("${name.snakeCase}", null)');
        } else {
          result.add(comments +
              '    data class ${name.pascalCase}($properties): FlutterRoute("${name.snakeCase}", $parameters)');
        }
        break;
      case KotlinCodeType.impl:
        final vals = method['arguments']
            .listValue
            .map((dynamic j) =>
                'val ${j.name} = args["${j.name}"] as? ${j["type"].stringValue}' +
                (j.isRequired
                    ? ' ?: throw IllegalArgumentException("Invalid argument: ${j.name}")'
                    : ''))
            .join('\n           ');
        result.add('''        if (call.method == "$identifier#$name") {
            $vals
            // invoke $name
            result.success($name(${method['arguments'].listValue.map((dynamic j) => j.name).join(', ')}))
            return true
        }'''
            .replaceDartTypeToKotlin);
        break;
    }
  }
  return result;
}

extension StringFaraday on String {
  String get replaceDartTypeToKotlin => replaceAll('bool', 'Boolean')
      .replaceAll('int', 'Int')
      .replaceAll('float', 'Float')
      .replaceAll('double', 'Double')
      .replaceAll('num', 'Double')
      .replaceAll('dynamic', 'Any')
      .replaceAll('null', 'Any?');
}
