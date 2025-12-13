class GenerationOptions {
  final bool useFinal;
  final bool makeNullable;
  final bool generateFromToJson;
  final bool generateCopyWith;
  final bool useRequired;
  final bool typesOnly;
  final bool generateDataClass;

  const GenerationOptions({
    this.useFinal = true,
    this.makeNullable = true,
    this.generateFromToJson = true,
    this.generateCopyWith = false,
    this.useRequired = false,
    this.typesOnly = false,
    this.generateDataClass = false,
  });

  GenerationOptions copyWith({
    bool? useFinal,
    bool? makeNullable,
    bool? generateFromToJson,
    bool? generateCopyWith,
    bool? useRequired,
    bool? typesOnly,
    bool? generateDataClass,
  }) {
    return GenerationOptions(
      useFinal: useFinal ?? this.useFinal,
      makeNullable: makeNullable ?? this.makeNullable,
      generateFromToJson: generateFromToJson ?? this.generateFromToJson,
      generateCopyWith: generateCopyWith ?? this.generateCopyWith,
      useRequired: useRequired ?? this.useRequired,
      typesOnly: typesOnly ?? this.typesOnly,
      generateDataClass: generateDataClass ?? this.generateDataClass,
    );
  }
}
