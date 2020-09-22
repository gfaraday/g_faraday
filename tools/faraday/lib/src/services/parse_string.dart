import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

const commonAnnotation = ['common'];
const routeAnnotation = ['entry'];

Map<String, Map<String, List<MethodDeclaration>>> parse({String sourceCode}) {
  final result = <String, Map<String, List<MethodDeclaration>>>{};

  final unit = parseString(content: sourceCode).unit;
  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration) {
      final clazzName = declaration.name.name;
      if (declaration.extendsClause.superclass.name.name != 'App') {
        result[clazzName] = {};
        break;
      }

      final commonMethods = <MethodDeclaration>[];
      final routeMethods = <MethodDeclaration>[];

      for (final method in declaration.childEntities) {
        if (method is MethodDeclaration && method.isStatic) {
          for (final metadata in method.metadata) {
            if (commonAnnotation.contains(metadata.name.name) ||
                routeAnnotation.contains(metadata.name.name)) {
              final rt = method.returnType.toString();
              final methodName = method.name.name;
              // 对应的 swift 和 kotlin 返回值为 Any?
              if ('null' == rt ||
                  'Future<JSON>' == rt ||
                  'Future<dynamic>' == rt) {
                if (commonAnnotation.contains(metadata.name.name)) {
                  commonMethods.add(method);
                } else {
                  routeMethods.add(method);
                }
              } else {
                throw '${metadata.name.name} 返回值必须为 Future<dynmaic> 或者 Future<JSON>. [${clazzName}:${methodName} -> ${rt}] 不合法';
              }
              break;
            }
          }
        }
      }

      print(
          '🔥 process app: $clazzName\n common(s):\n  ${commonMethods.join(',\n  ')}\nroute(s):\n  ${routeMethods.join(',\n  ')}');
      result[clazzName] = {'common': commonMethods, 'route': routeMethods};
    }
  }
  return result;
}

class Parameter {
  final bool isRequired;
  final String name;
  final String type;

  const Parameter(this.name, this.type, this.isRequired);

  factory Parameter.from(FormalParameter p) {
    if (p is SimpleFormalParameter) {
      return Parameter(
          p.identifier.name,
          p.type.toString(),
          p.isRequired ||
              p.metadata.indexWhere((a) => a.name.name == 'required') != -1);
    }
    if (p is DefaultFormalParameter) {
      return Parameter.from(p.parameter);
    }
    throw 'Unsupport parameter: $p';
  }

  Map<String, dynamic> get info =>
      {'name': name, 'type': type, 'isRequired': isRequired};
  String get swift => '$name: $type${isRequired ? '' : '?'}';
}

extension MethodDeclarationFaraday on MethodDeclaration {
  String get comments =>
      documentationComment?.childEntities?.map((s) => s.toString())?.join('\n');
  String get funcName => name.name;
  List<Parameter> get arguments => parameters.parameters
      .map((p) => Parameter.from(p))
      .where((p) => p.type != 'BuildContext')
      .toList();

  Map<String, dynamic> get info => {
        'comments': comments,
        'name': funcName,
        'arguments': arguments.map((arg) => arg.info).toList(),
      };
}
