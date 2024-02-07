import 'dart:convert';

import 'package:cancellation_token_http/http.dart';

typedef UriBuilder = Uri Function({String? url, String? host, int? port, String? path, Map<String, dynamic>? queryParameters});
typedef ErrorHandler = Response Function(Response error);

abstract class AcApiClient {

  final Uri? baseUri;
  final UriBuilder? _uriBuilder;

  AcApiClient({this.baseUri, UriBuilder? uriBuilder}) :
        assert(baseUri != null || uriBuilder != null, 'Either `baseUri` or `uriBuilder` must be specified'),
        _uriBuilder = uriBuilder;

  Future<Response> get(String path, {String? host, String? url, Map<String, String>? headers, Map<String, dynamic>? queryParameters});

  Future<Response> post(String path,
      {String? host, String? url, Map<String, String>? headers, body, Encoding? encoding, Map<String, String>? queryParameters});

  Future<Response> put(String path,
      {String? host, String? url, Map<String, String>? headers, body, Encoding? encoding, Map<String, String>? queryParameters});

  Future<Response> patch(String path,
      {String? host, String? url, Map<String, String>? headers, body, Encoding? encoding, Map<String, String>? queryParameters});

  Future<Response> delete(String path,
      {String? host, String? url, Map<String, String>? headers, dynamic body, Map<String, String>? queryParameters});


  UriBuilder get uriBuilder => _uriBuilder ?? defaultUriBuilder;

  UriBuilder get defaultUriBuilder
      => ({String? url, String? host, int? port, String? path, Map<String, dynamic>? queryParameters}) {
            final Uri uri;
            if (url != null && (url.startsWith('http://') || url.startsWith('https://'))) {
              // full URL
              uri = Uri.parse(url);
            } else {
              // `url` is not specified or is a relative or an absolute path, use it as a path
              // if `path` itself is not specified. If `path` is specified, it will be used and
              // `url` is ignored
              path ??= url;
              uri = baseUri!;
            }
            if (path?.startsWith('/') == false) {
              path = '${uri.path}/$path';
            }
            return uri.replace(host: host, path: path, port: port, queryParameters: queryParameters);
          };

}

abstract interface class AcApi {
  AcApiClient get apiClient;
}