class Tag {
  /// Identifiant de l'étiquette
  final String id;
  /// Label de l'étiquette
  final String label;
  /// Definition du label
  final String definition;
  /// Label de l'étiquette en anglais
  final String labelEN;
  /// Definition du label en anglais
  final String definitionEN;
  /// Si l'etiquette est activée ou non
  bool isVisible;

  Tag({this.id, this.label, this.definition, this.labelEN, this.definitionEN,
    this.isVisible = false});
  Map<String, dynamic> toJson() => {
    'label':this.label,
    'definition':this.definition,
    'labelEN': this.labelEN,
    'definitionEN': this.definitionEN,
  };
}