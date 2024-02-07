
class ApiException<ERR> implements Exception {
  final int code;
  final String? reason;
  final ERR? apiError;

  ApiException(this.code, this.reason, this.apiError);

  @override
  String toString() => '$code $reason';
}
