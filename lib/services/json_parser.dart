import 'dart:convert';

import '../models/field_info.dart';
import 'type_detector.dart';

class JsonParser {
  final Map<String, Map<String, dynamic>> nestedClasses = {};

  ParseResult parseJson(String jsonString, String className) {
    nestedClasses.clear();

    try {
      final jsonData = jsonDecode(jsonString);

      if (jsonData is! Map<String, dynamic>) {
        throw FormatException('JSON must be an object');
      }

      final fields = _analyzeFields(jsonData, className);

      return ParseResult(
        success: true,
        mainClassName: className,
        fields: fields,
        nestedClasses: Map.from(nestedClasses),
      );
    } catch (e) {
      return ParseResult(
        success: false,
        error: e.toString(),
        mainClassName: className,
        fields: [],
        nestedClasses: {},
      );
    }
  }

  List<FieldInfo> _analyzeFields(
    Map<String, dynamic> json,
    String parentClassName,
  ) {
    final fields = <FieldInfo>[];

    json.forEach((key, value) {
      final fieldName = TypeDetector.toCamelCase(key);
      final baseType = TypeDetector.detectType(value);

      if (baseType == 'List' && value is List) {
        final itemType = _handleList(value, fieldName, parentClassName);
        fields.add(
          FieldInfo(
            name: fieldName,
            type: 'List',
            isList: true,
            listItemType: itemType,
            isNullable: value.isEmpty,
          ),
        );
      } else if (baseType == 'Map' && value is Map<String, dynamic>) {
        final nestedClassName = TypeDetector.toPascalCase(fieldName);
        nestedClasses[nestedClassName] = value;
        _analyzeFields(value, nestedClassName); // Recursive analysis

        fields.add(
          FieldInfo(name: fieldName, type: nestedClassName, isNullable: false),
        );
      } else {
        fields.add(
          FieldInfo(name: fieldName, type: baseType, isNullable: value == null),
        );
      }
    });

    return fields;
  }

  String _handleList(List list, String fieldName, String parentClassName) {
    if (list.isEmpty) return 'dynamic';

    final firstItem = list.first;
    final itemType = TypeDetector.detectType(firstItem);

    if (itemType == 'Map' && firstItem is Map<String, dynamic>) {
      final nestedClassName = TypeDetector.toPascalCase(fieldName);
      // Remove trailing 's' if exists for singular class name
      final singularClassName =
          nestedClassName.endsWith('s') && nestedClassName.length > 1
          ? nestedClassName.substring(0, nestedClassName.length - 1)
          : nestedClassName;

      nestedClasses[singularClassName] = firstItem;
      _analyzeFields(firstItem, singularClassName); // Recursive analysis

      return singularClassName;
    } else if (itemType == 'List') {
      return 'dynamic'; // Nested lists not fully supported
    }

    return TypeDetector.detectListItemType(list) ?? 'dynamic';
  }
}

class ParseResult {
  final bool success;
  final String? error;
  final String mainClassName;
  final List<FieldInfo> fields;
  final Map<String, Map<String, dynamic>> nestedClasses;

  ParseResult({
    required this.success,
    this.error,
    required this.mainClassName,
    required this.fields,
    required this.nestedClasses,
  });
}
