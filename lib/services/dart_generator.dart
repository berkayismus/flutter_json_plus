import '../models/field_info.dart';
import '../models/generation_options.dart';
import 'json_parser.dart';

class DartGenerator {
  String generateCode(ParseResult parseResult, GenerationOptions options) {
    final buffer = StringBuffer();

    // Generate main class
    _generateClass(
      buffer,
      parseResult.mainClassName,
      parseResult.fields,
      options,
    );

    // Generate nested classes (alphabetically sorted)
    if (parseResult.nestedClasses.isNotEmpty) {
      final sortedClassNames = parseResult.nestedClasses.keys.toList()..sort();

      for (final className in sortedClassNames) {
        buffer.writeln();
        final jsonData = parseResult.nestedClasses[className]!;
        final fields = _analyzeFieldsFromJson(jsonData);
        _generateClass(buffer, className, fields, options);
      }
    }

    return buffer.toString();
  }

  void _generateClass(
    StringBuffer buffer,
    String className,
    List<FieldInfo> fields,
    GenerationOptions options,
  ) {
    buffer.writeln('class $className {');

    // Generate fields
    if (!options.typesOnly) {
      _generateFields(buffer, fields, options);
      buffer.writeln();

      // Generate constructor
      _generateConstructor(buffer, className, fields, options);

      // Generate fromJson
      if (options.generateFromToJson) {
        buffer.writeln();
        _generateFromJson(buffer, className, fields, options);
      }

      // Generate toJson
      if (options.generateFromToJson) {
        buffer.writeln();
        _generateToJson(buffer, fields);
      }

      // Generate copyWith
      if (options.generateCopyWith) {
        buffer.writeln();
        _generateCopyWith(buffer, className, fields, options);
      }

      // Generate == and hashCode
      if (options.generateDataClass) {
        buffer.writeln();
        _generateEquality(buffer, fields);
        buffer.writeln();
        _generateHashCode(buffer, fields);
      }
    } else {
      // Types only mode
      _generateFields(buffer, fields, options);
    }

    buffer.writeln('}');
  }

  void _generateFields(
    StringBuffer buffer,
    List<FieldInfo> fields,
    GenerationOptions options,
  ) {
    for (final field in fields) {
      final keyword = options.useFinal ? 'final ' : '';
      final nullableMarker = options.makeNullable && field.type != 'bool'
          ? '?'
          : '';
      final fullType = field.isList
          ? 'List<${field.listItemType ?? 'dynamic'}>$nullableMarker'
          : '${field.type}$nullableMarker';

      buffer.writeln('  $keyword$fullType ${field.name};');
    }
  }

  void _generateConstructor(
    StringBuffer buffer,
    String className,
    List<FieldInfo> fields,
    GenerationOptions options,
  ) {
    buffer.writeln('  $className({');

    for (final field in fields) {
      final requiredKeyword = options.useRequired ? 'required ' : '';
      buffer.writeln('    ${requiredKeyword}this.${field.name},');
    }

    buffer.writeln('  });');
  }

  void _generateFromJson(
    StringBuffer buffer,
    String className,
    List<FieldInfo> fields,
    GenerationOptions options,
  ) {
    buffer.writeln(
      '  factory $className.fromJson(Map<String, dynamic> json) {',
    );
    buffer.writeln('    return $className(');

    for (final field in fields) {
      final jsonKey = _toJsonKey(field.name);

      if (field.isList) {
        final itemType = field.listItemType ?? 'dynamic';
        if (itemType == 'dynamic' ||
            itemType == 'int' ||
            itemType == 'double' ||
            itemType == 'String' ||
            itemType == 'bool') {
          buffer.writeln(
            '      ${field.name}: (json[\'$jsonKey\'] as List?)?.cast<$itemType>(),',
          );
        } else {
          // Nested class list
          buffer.writeln(
            '      ${field.name}: (json[\'$jsonKey\'] as List?)?.map((e) => $itemType.fromJson(e)).toList(),',
          );
        }
      } else if (_isCustomType(field.type)) {
        // Nested class
        buffer.writeln(
          '      ${field.name}: json[\'$jsonKey\'] != null ? ${field.type}.fromJson(json[\'$jsonKey\']) : null,',
        );
      } else {
        // Primitive type
        buffer.writeln('      ${field.name}: json[\'$jsonKey\'],');
      }
    }

    buffer.writeln('    );');
    buffer.writeln('  }');
  }

  void _generateToJson(StringBuffer buffer, List<FieldInfo> fields) {
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');

    for (final field in fields) {
      final jsonKey = _toJsonKey(field.name);

      if (field.isList) {
        final itemType = field.listItemType ?? 'dynamic';
        if (_isCustomType(itemType)) {
          buffer.writeln(
            '      \'$jsonKey\': ${field.name}?.map((e) => e.toJson()).toList(),',
          );
        } else {
          buffer.writeln('      \'$jsonKey\': ${field.name},');
        }
      } else if (_isCustomType(field.type)) {
        buffer.writeln('      \'$jsonKey\': ${field.name}?.toJson(),');
      } else {
        buffer.writeln('      \'$jsonKey\': ${field.name},');
      }
    }

    buffer.writeln('    };');
    buffer.writeln('  }');
  }

  void _generateCopyWith(
    StringBuffer buffer,
    String className,
    List<FieldInfo> fields,
    GenerationOptions options,
  ) {
    buffer.writeln('  $className copyWith({');

    for (final field in fields) {
      final fullType = field.isList
          ? 'List<${field.listItemType ?? 'dynamic'}>?'
          : '${field.type}?';
      buffer.writeln('    $fullType ${field.name},');
    }

    buffer.writeln('  }) {');
    buffer.writeln('    return $className(');

    for (final field in fields) {
      buffer.writeln(
        '      ${field.name}: ${field.name} ?? this.${field.name},',
      );
    }

    buffer.writeln('    );');
    buffer.writeln('  }');
  }

  void _generateEquality(StringBuffer buffer, List<FieldInfo> fields) {
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) {');
    buffer.writeln('    if (identical(this, other)) return true;');
    buffer.writeln();
    buffer.writeln(
      '    return other is ${fields.isNotEmpty ? _getClassName(fields) : 'Object'} &&',
    );

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final isLast = i == fields.length - 1;
      final ending = isLast ? ';' : ' &&';

      if (field.isList) {
        buffer.writeln(
          '      _listEquals(other.${field.name}, ${field.name})$ending',
        );
      } else {
        buffer.writeln('      other.${field.name} == ${field.name}$ending');
      }
    }

    buffer.writeln('  }');

    // Add list equality helper if needed
    if (fields.any((f) => f.isList)) {
      buffer.writeln();
      buffer.writeln('  bool _listEquals(List? a, List? b) {');
      buffer.writeln('    if (a == null) return b == null;');
      buffer.writeln(
        '    if (b == null || a.length != b.length) return false;',
      );
      buffer.writeln('    for (int i = 0; i < a.length; i++) {');
      buffer.writeln('      if (a[i] != b[i]) return false;');
      buffer.writeln('    }');
      buffer.writeln('    return true;');
      buffer.writeln('  }');
    }
  }

  void _generateHashCode(StringBuffer buffer, List<FieldInfo> fields) {
    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode {');

    if (fields.isEmpty) {
      buffer.writeln('    return 0;');
    } else if (fields.length == 1) {
      buffer.writeln('    return ${fields.first.name}.hashCode;');
    } else {
      buffer.write('    return ');
      for (int i = 0; i < fields.length; i++) {
        final field = fields[i];
        if (i > 0) buffer.write(' ^ ');
        buffer.write('${field.name}.hashCode');
      }
      buffer.writeln(';');
    }

    buffer.writeln('  }');
  }

  List<FieldInfo> _analyzeFieldsFromJson(Map<String, dynamic> json) {
    final fields = <FieldInfo>[];

    json.forEach((key, value) {
      final fieldName = _toCamelCase(key);
      String type = 'dynamic';
      bool isList = false;
      String? listItemType;

      if (value is bool) {
        type = 'bool';
      } else if (value is int) {
        type = 'int';
      } else if (value is double) {
        type = 'double';
      } else if (value is String) {
        type = 'String';
      } else if (value is List) {
        isList = true;
        if (value.isNotEmpty) {
          final firstItem = value.first;
          if (firstItem is Map) {
            listItemType = _toPascalCase(fieldName);
            if (listItemType.endsWith('s') && listItemType.length > 1) {
              listItemType = listItemType.substring(0, listItemType.length - 1);
            }
          } else if (firstItem is int) {
            listItemType = 'int';
          } else if (firstItem is double) {
            listItemType = 'double';
          } else if (firstItem is String) {
            listItemType = 'String';
          } else if (firstItem is bool) {
            listItemType = 'bool';
          }
        }
      } else if (value is Map) {
        type = _toPascalCase(fieldName);
      }

      fields.add(
        FieldInfo(
          name: fieldName,
          type: type,
          isList: isList,
          listItemType: listItemType,
          isNullable: value == null,
        ),
      );
    });

    return fields;
  }

  String _toJsonKey(String fieldName) {
    // Convert camelCase to snake_case or keep original
    // For now, keeping it simple - same as field name
    return fieldName;
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) return input;
    final pascalCase = _toPascalCase(input);
    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return input;
    final words = input.split(RegExp(r'[\s_]+'));
    return words
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join('');
  }

  bool _isCustomType(String type) {
    const primitiveTypes = [
      'int',
      'double',
      'String',
      'bool',
      'dynamic',
      'num',
    ];
    return !primitiveTypes.contains(type);
  }

  String _getClassName(List<FieldInfo> fields) {
    // This is a placeholder - in real implementation, pass className
    return 'ClassName';
  }
}
