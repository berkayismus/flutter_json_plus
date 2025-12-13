class TypeDetector {
  static String detectType(dynamic value) {
    if (value == null) return 'dynamic';
    if (value is bool) return 'bool';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is num) return 'double'; // Fallback for numbers
    if (value is String) return 'String';
    if (value is List) return 'List';
    if (value is Map) return 'Map';
    return 'dynamic';
  }

  static String? detectListItemType(List list) {
    if (list.isEmpty) return 'dynamic';

    final firstItem = list.first;
    final firstType = detectType(firstItem);

    // Check if all items have the same type
    final allSameType = list.every((item) => detectType(item) == firstType);

    if (allSameType) {
      return firstType;
    }

    return 'dynamic';
  }

  static String toPascalCase(String input) {
    if (input.isEmpty) return input;

    // Remove special characters and split by common delimiters
    final words = input
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\s]'), '')
        .split(RegExp(r'[\s_]+'))
        .where((word) => word.isNotEmpty);

    return words
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join('');
  }

  static String toCamelCase(String input) {
    if (input.isEmpty) return input;

    final pascalCase = toPascalCase(input);
    if (pascalCase.isEmpty) return pascalCase;

    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }
}
