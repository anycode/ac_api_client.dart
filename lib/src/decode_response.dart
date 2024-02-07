import 'package:ac_http_client/src/response_ext.dart';
import 'package:cancellation_token_http/http.dart' as http;

import 'model/paged.dart';

@Deprecated('Use Response.jsonBodyToObject<T>(converter)')
T decodeJson<T>(http.Response response, T Function(Map<String, dynamic> json) converter) {
  return response.jsonBodyToObject<T>(converter);
}

@Deprecated('Use Response.jsonBodyToObject2<T, S>(converter)')
T decodeJson2<T, S>(http.Response response, T Function(S json) converter) {
  return response.jsonBodyToObject2<T, S>(converter);
}

@Deprecated('Use Response.jsonBodyToList<T>(converter)')
List<T> decodeJsonArray<T>(http.Response response, T Function(Map<String, dynamic> json) converter) {
  return response.jsonBodyToList<T>(converter);
}

@Deprecated('Use Response.jsonBodyToList2<T, S>(converter)')
List<T> decodeJsonArray2<T, S>(http.Response response, T Function(S json) converter) {
  return response.jsonBodyToList2<T, S>(converter);
}

@Deprecated('Use Response.jsonBodyToPaged<T>(converter)')
Paged<T> decodeJsonPaged<T>(http.Response response, T Function(Map<String, dynamic> json) converter) {
  return response.jsonBodyToPaged<T>(converter);
}

@Deprecated('Use Response.jsonBodyToPaged2<T, S>(converter)')
Paged<T> decodeJsonPaged2<T, S>(http.Response response, T Function(S json) converter) {
  return response.jsonBodyToPaged2<T, S>(converter);
}
