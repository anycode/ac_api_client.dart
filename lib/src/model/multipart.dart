/// Type of a field in a multipart body
enum MultipartFieldType { field, media }

/// A field in a multipart body
class MultipartField {
  /// Creates a new [MultipartField]
  MultipartField({
    required this.name,
    required this.value,
    this.type = MultipartFieldType.field,
    this.contentType,
    this.filename,
  });

  /// Creates a new [MultipartField] of type [MultipartFieldType.media]
  MultipartField.media({
    String? name,
    required this.value,
    this.contentType,
    required this.filename,
  })  : type = MultipartFieldType.media,
        name = name ?? filename!;

  final String? filename;
  final String name;
  final dynamic value;
  final MultipartFieldType type;
  final String? contentType;
}

/// Maps a [Map] to a list of [MultipartField]
List<MultipartField> mapToMultipartFields(Map<String, dynamic> map) =>
    map.entries.map((e) => MultipartField(name: e.key, value: e.value)).toList();
