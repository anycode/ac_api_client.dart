
class ApiException<ERR> implements Exception {
  final int code;
  final String? reason;
  String? path;
  final Map<String, String>? headers;
  final ERR? apiError;

  ApiException(this.code, this.reason, this.headers, this.apiError);

  @override
  String toString() => '$code $reason';
}
