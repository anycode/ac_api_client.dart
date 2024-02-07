enum MultipartFieldType { field, media }

class MultipartField {
  MultipartField({
    required this.name,
    required this.value,
    this.type = MultipartFieldType.field,
    this.contentType,
    this.filename,
  });

  final String? filename;
  final String name;
  final dynamic value;
  final MultipartFieldType type;
  final String? contentType;
}
