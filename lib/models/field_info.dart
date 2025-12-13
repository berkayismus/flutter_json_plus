class FieldInfo {
  final String name;
  final String type;
  final bool isNullable;
  final bool isList;
  final String? listItemType;

  const FieldInfo({
    required this.name,
    required this.type,
    this.isNullable = false,
    this.isList = false,
    this.listItemType,
  });

  String get dartType {
    if (isList) {
      return 'List<${listItemType ?? 'dynamic'}>';
    }
    return type;
  }

  String get fullType {
    final baseType = dartType;
    return isNullable ? '$baseType?' : baseType;
  }
}
