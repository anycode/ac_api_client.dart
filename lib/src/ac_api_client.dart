import 'dart:convert';
import 'dart:io';

import 'package:ac_api_client/ac_api_client.dart';

/// Method signature for URI builder. Takes parameters passed to `get`, `post`, `put`, `patch` and `delete` methods and returns a URI.
typedef UriBuilder = Uri Function({String? url, String? host, int? port, String? path, Map<String, dynamic>? queryParameters});

/// Method signature for error handler. Takes error response and returns it modified or unmodified or new.
typedef ErrorHandler = Response Function(Response error);

/// Base class for all API clients. Defines default handlers for all methods.
abstract class AcApiClient {
  /// Base URI for all requests which don't specify it explicitly.
  final Uri? baseUri;
  final UriBuilder? _uriBuilder;
  final ContentType _defaultContentType;

  /// Creates an API client with optional base URI and URI builder. If no URI builder is provided, the default URI builder is used.
  /// Either `baseUri` or `uriBuilder` must be specified. If both are specified, `uriBuilder` takes precedence and uses `baseUri` as a base.
  /// Optional [defaultContentType] specifies the default encoding of the body when it's a List, a Map or an Object,
  /// default is [ContentType.json], other possible value is [ContentTypeExt.formUrlEncoded]. Content type may be changed in requests by
  /// setting the `content-type` header. So if the defaultContentType is [ContentType.json] and the body is a Map and you want
  /// to send body as form data, you must set the `content-type` header to `application/x-www-form-urlencoded`. On the other hand if the
  /// defaultContentType is [ContentTypeExt.formUrlEncoded] and the body is a Map or a List or an Object and you want to send it as JSON,
  /// you must set the `content-type` header to `application/json` in the request.
   AcApiClient({this.baseUri, UriBuilder? uriBuilder, ContentType? defaultContentType})
      : assert(baseUri != null || uriBuilder != null, 'Either `baseUri` or `uriBuilder` must be specified'),
        _uriBuilder = uriBuilder,
        _defaultContentType = defaultContentType ?? ContentType.json;

  /// Handles GET requests and returns response. [baseUri] is used as a base for the request.
  ///
  /// Mandatory [path] parameter contains the path of the request. If [path] starts with a slash (`/`), it will be used as an absolute
  /// path and will replace existing path of the [baseUri] or [url]. Otherwise [path] will be appended to the path of the [baseUri] or [url].
  /// Optional [host] parameter contains the host of the request and overrides host part of the [baseUri].
  /// Optional [url] parameter contains the full URL of the request and overrides whole [baseUri].
  /// Optional [headers] parameter contains extra headers of the request.
  /// Optional [queryParameters] parameter contains extra query parameters of the request.
  /// Optional [timeout] parameter contains the timeout of the request.
  /// Optional [cancelRunning] parameter specifies if the running request for the same URI should be cancelled.
  ///
  /// If you need to override whole URL, use [url] and use empty string as a [path]. eg.
  /// ```dart
  /// get('', url: 'https://example.com/path');
  /// ```
  /// or you may override only [host] and use [path], eg.
  /// ```dart
  /// get('/path', host: 'example.com');
  /// ```
  Future<Response> get(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Handles POST requests and returns response. [baseUri] is used as a base for the request.
  ///
  /// Optional [body] parameter contains the body of the request.
  /// Optional [encoding] parameter contains the encoding of the body and is used when converting [body] to a string.
  /// Same rules applies for other parameters as in [get].
  Future<Response> post(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Handles POST requests with multipart form data and returns response. [baseUri] is used as a base for the request.
  ///
  /// Optional [fields] parameter contains the fields of the request.
  /// Same rules applies for other parameters as in [get].
  Future<Response> postMultipart(
    path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    List<MultipartField>? fields,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Handles PUT requests and returns response. [baseUri] is used as a base for the request.
  ///
  /// Same rules applies for parameters as in [post].
  Future<Response> put(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Handles PUT requests with multipart form data and returns response. [baseUri] is used as a base for the request.
  ///
  /// Same rules applies for other parameters as in [post].
  Future<Response> putMultipart(
    path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    List<MultipartField>? fields,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Handles PATCH requests and returns response. [baseUri] is used as a base for the request.
  ///
  /// Same rules applies for parameters as in [post].
  Future<Response> patch(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Handles PATCH requests with multipart form data and returns response. [baseUri] is used as a base for the request.
  ///
  /// Same rules applies for other parameters as in [post].
  Future<Response> patchMultipart(
    path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    List<MultipartField>? fields,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Handles DELETE requests and returns response. [baseUri] is used as a base for the request.
  ///
  /// Same rules applies for parameters as in [post].
  Future<Response> delete(String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Extra non-standard HTTP method for executing arbitrary code on the server side. For example if you need to
  /// run some calculations on the server side, you can use this method. You don't expect some data to be returned
  /// immediately, so you should use [get] or [post] instead. You just get response code to check if the code
  /// was run successfully or not.
  ///
  /// Same rules applies for parameters as in [post].
  ///
  /// Requires server which supports this method. eg. [Conduit] with AnyCode patch applied.
  Future<Response> exec(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Extra non-standard HTTP method for purging data on the server side.
  ///
  /// Same rules applies for parameters as in [post].
  ///
  /// Requires server which supports this method. eg. [Conduit] with AnyCode patch applied.
  Future<Response> purge(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Extra non-standard HTTP method for resetting data on the server side.
  ///
  /// Same rules applies for parameters as in [post].
  ///
  /// Requires server which supports this method. eg. [Conduit] with AnyCode patch applied.
  Future<Response> reset(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Extra non-standard HTTP method for locking data on the server side.
  ///
  /// Same rules applies for parameters as in [post].
  ///
  /// Requires server which supports this method. eg. [Conduit] with AnyCode patch applied.
  Future<Response> lock(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Extra non-standard HTTP method for unlocking data on the server side.
  ///
  /// Same rules applies for parameters as in [post].
  ///
  /// Requires server which supports this method. eg. [Conduit] with AnyCode patch applied.
  Future<Response> unlock(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  });

  /// Returns default [ContentType] used for encoding and decoding of the request body if not specified in the headers.
  ContentType get defaultContentType => _defaultContentType;

  /// Returns [uriBuilder] used for dynamic building of the request URI. If no [uriBuilder] is specified in the constructor,
  /// the [defaultUriBuilder] is used.
  UriBuilder get uriBuilder => _uriBuilder ?? defaultUriBuilder;

  /// Default [uriBuilder] used for dynamic building of the request URI.
  /// If [url] is specified and starts with `http://` or `https://`, it will be used as a full URL. Other parameters are not
  /// needed then (but they still may be used).
  /// If [url] is specified and don't start with `http://` or `https://`, it's then used as a path, but only when [path] itself
  /// is not specified.
  /// If path starts with slash (`/`), it will be used as an absolute path and will replace existing path of `uri`.
  /// In the final `uri` `host`, `port`, `path` and `queryParameters` are replaced with the values passed.
  ///
  /// It's always better to not mix [url] with other parameters. Either use [url] alone, or [path] to extend
  /// or replace the path of the [baseUri]. Use other parameters only when necessary.
  ///
  /// eg.
  /// ```dart
  /// defaultUriBuilder(url: 'https://example.com/path');
  /// # returns URI https://example.com/path
  ///
  /// defaultUriBuilder(url: '/path', host: 'example.com');
  /// # returns URI https://example.com/path, `url` is used as an absolute path
  ///
  /// defaultUriBuilder(url: 'https://example.com/path', path: '/other-path', port: 8080);
  /// # returns URI https://example.com:8080/other-path,
  /// `path` replaces existing path of the URL
  ///
  /// defaultUriBuilder(url: 'https://example.com/path', path: 'sub-path');
  /// # returns URI https://example.com/path/sub-path,
  /// `path` is appended to the existing path of the URL
  ///
  /// defaultUriBuilder(path: '/other-path');
  /// # returns URI https://baseuri.host/other-path,
  /// #`path` replaces existing path of the `baseUri`
  ///
  /// defaultUriBuilder(path: 'sub-path');
  /// # returns URI https://baseuri.host/baseuri-path/sub-path,
  /// # `path` is appended to the existing path of the `baseUri`
  /// ```
  UriBuilder get defaultUriBuilder => ({String? url, String? host, int? port, String? path, Map<String, dynamic>? queryParameters}) {
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

/// Base class for API interfaces. Contains an instance of API client.
abstract interface class AcApi {
  AcApiClient get apiClient;
}
