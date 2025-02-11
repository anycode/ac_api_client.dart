class ApiError {
  ApiError({required this.statusCode, required this.message, this.errors});

  factory ApiError.fromJson(Map<String, dynamic> json, int statusCode) {
    return ApiError(
      statusCode: json["statusCode"] as int? ?? statusCode,
      message: json["message"] as String? ?? json["error"] as String? ?? json["reason"] as String? ?? 'Unknown error',
      errors: json["errors"] == null ? null : List.of(json["errors"]).map((err) => _ApiError.fromJson(err)).toList(),
    );
  }

  int statusCode;
  String message;
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
