import 'package:ac_api_client/ac_api_client.dart';

class ApiError {
  ApiError({required this.statusCode, required this.message, this.path, this.headers, this.datetime, this.errors});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json["statusCode"] as int,
      message: json["message"] as String,
      path: json["path"] as String?,
      headers: json["headers"] as Map<String, String>?,
      datetime: json["datetime"] == null ? null : DateTimeConverter().fromJson(json["datetime"]),
      errors: json["errors"] == null ? null : List.of(json["errors"]).map((i) => _ApiError(i)).toList(),
    );
  }

  int statusCode;
  String message;
  String? path;
  final Map<String, String>? headers;
  DateTime? datetime;
  List<_ApiError>? errors;

  @override
  String toString() => '$statusCode: $message';
}

class _ApiError {
  _ApiError(this.reason);
  factory _ApiError.fromJson(Map<String, dynamic> json) {
    return _ApiError(json["reason"] as String);
  }

  String reason;
}
