
import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

@JsonSerializable(createToJson: false)
class ApiError {
  ApiError({required this.status, required this.error, this.message, this.path, this.headers, this.datetime});
  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);

  int? status;
  String error;
  String? message;
  String? path;
  final Map<String, String>? headers;
  DateTime? datetime;
  List<_ApiErrorErrors>? _errors;
  List<_ApiErrorArguments>? _arguments;

  @override
  String toString() => '$status: $message';
}

@JsonSerializable(createToJson: false)
class _ApiErrorErrors {
  _ApiErrorErrors();
  factory _ApiErrorErrors.fromJson(Map<String, dynamic> json) => _$ApiErrorErrorsFromJson(json);

  List<String>? codes;
}

@JsonSerializable(createToJson: false)
class _ApiErrorArguments {
  _ApiErrorArguments();
  factory _ApiErrorArguments.fromJson(Map<String, dynamic> json) => _$ApiErrorArgumentsFromJson(json);

  List<String>? codes;
}
