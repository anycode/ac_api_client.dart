import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ac_dart/ac_dart.dart';
import 'package:cancellation_token_http/http.dart';
import 'package:http_extensions/http_extensions.dart';
import 'package:http_extensions_base_url/http_extensions_base_url.dart';
import 'package:http_extensions_headers/http_extensions_headers.dart';
import 'package:http_extensions_log/http_extensions_log.dart';
import 'package:http_extensions_retry/http_extensions_retry.dart';
import 'package:logging/logging.dart';

import 'ac_api_client.dart';
import 'logging/nobinary_log_extension.dart';
import 'logging/performance_extension.dart';
import 'model/api_error.dart';
import 'model/api_exception.dart';
import 'model/media.dart';
import 'model/multipart.dart';

class HttpApiClient extends AcApiClient {
  final Client _client;
  final ErrorHandler? errorHandler;
  final Logger? errorLogger;
  final Duration? defaultTimeout;

  final cancellationTokens = <String, CancellationToken>{};

  HttpApiClient({
    super.baseUri,
    required BaseClient inner,
    LogOptions? logOptions,
    HeadersOptions? headersOptions,
    RetryOptions? retryOptions,
    Logger? logger,
    Logger? baseUrlLogger,
    Logger? retryLogger,
    Logger? headerLogger,
    Logger? performanceLogger,
    Logger? httpLogger,
    Logger? errorLogger,
    super.uriBuilder,
    this.errorHandler,
    this.defaultTimeout = const Duration(minutes: 5),
  })  : errorLogger = errorLogger ?? logger ?? Logger('Error'),
        _client = ExtendedClient(
          inner: inner,
          extensions: [
            if (baseUri != null)
              BaseUrlExtension(
                logger: baseUrlLogger ?? logger ?? Logger('BaseUrl'),
                defaultOptions: BaseUrlOptions(
                  url: baseUri,
                ),
              ),
            RetryExtension(
              logger: retryLogger ?? logger ?? Logger('Retry'),
              defaultOptions: retryOptions ??
                  RetryOptions(
                    retries: 3, // Number of retries before a failure
                    retryInterval: const Duration(seconds: 5), // Interval between each retry
                    retryEvaluator: (error, response) => error != null,
                  ),
            ),
            HeadersExtension(
              logger: headerLogger ?? logger ?? Logger('Headers'),
              defaultOptions: headersOptions ??
                  HeadersOptions(
                    headersBuilder: (request) => {
                      'Content-Type': ContentType.json.mimeType,
                    },
                  ),
            ),
            PerformanceExtension(
              logger: performanceLogger ?? logger ?? Logger('Performance'),
              defaultOptions: logOptions ?? const LogOptions(),
            ),
            // Keep LogExtension last as it wraps the request with BufferedRequest and
            // headersBuilder() of HeadersExtension won't modify original request and no
            // extra headers are sent
            NoBinaryLogExtension(
              logger: httpLogger ?? logger ?? Logger('Http'),
              defaultOptions: logOptions ?? const LogOptions(),
            ),
          ],
        );

  @override
  Future<Response> get(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  }) {
    return _sendUnstreamed(
      'GET',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  @override
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
  }) {
    return _sendUnstreamed(
      'POST',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      body: body,
      encoding: encoding,
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  Future<Response> postMultipart(
    path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    List<MultipartField>? fields,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  }) {
    return _sendMultipart(
      'POST',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      fields: fields,
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  @override
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
  }) {
    return _sendUnstreamed(
      'PUT',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      body: body,
      encoding: encoding,
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  Future<Response> putMultipart(
    path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    List<MultipartField>? fields,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  }) {
    return _sendMultipart(
      'PUT',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      fields: fields,
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  @override
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
  }) {
    return _sendUnstreamed(
      'PATCH',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      body: body,
      encoding: encoding,
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  Future<Response> patchMultipart(
    path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    List<MultipartField>? fields,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  }) async {
    return _sendMultipart(
      'PATCH',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      fields: fields,
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  // DELETE by default doesn't support body, so pass it manually via http.Request
  @override
  Future<Response> delete(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  }) {
    return _sendUnstreamed(
      'DELETE',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      body: body,
      encoding: encoding,
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  Future<Response> exec(
    String path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  }) {
    return _sendUnstreamed(
      'EXEC',
      uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
      body: body,
      encoding: encoding,
      headers: headers,
      timeout: timeout,
      cancelRunning: cancelRunning,
    );
  }

  void close() {
    _client.close();
  }

  Future<StreamedResponse> send(BaseRequest request, {CancellationToken? cancellationToken}) {
    return _client.send(request, cancellationToken: cancellationToken);
  }

  // cancelable version of BaseClient._sendUnstreamed(...)
  Future<Response> _sendUnstreamed(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    bool cancelRunning = false,
  }) async {
    var request = Request(method, url);

    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        if (request.headers.containsKey('content-type') &&
            [ContentType.json.value, ContentTypeExt.errorJson.value].contains(request.headers['content-type'])) {
          request.body = json.encode(body);
        } else {
          request.bodyFields = body.cast<String, String>();
        }
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }

    final ctName = '$method ${url.path}';
    var ct = cancellationTokens[ctName];
    if (cancelRunning && ct != null && !ct.isCancelled) {
      log('canceling request $ctName with token ${ct.hashCode}', level: Level.FINER.value);
      ct.cancel();
    }
    try {
      cancellationTokens[ctName] = CancellationToken();
      timeout ??= defaultTimeout;
      final req = send(request, cancellationToken: cancellationTokens[ctName]);
      final resp = timeout != null ? await req.timeout(timeout) : await req;
      cancellationTokens.remove(ctName);
      return _throwIfError(await Response.fromStream(resp));
    } on CancelledException {
      log('request $ctName canceled', level: Level.FINER.value);
      rethrow;
    }
  }

  Future<Response> _sendMultipart(
    String method,
    Uri url, {
    List<MultipartField>? fields,
    Map<String, String>? headers,
    Duration? timeout,
    bool cancelRunning = false,
  }) async {
    var request = MultipartRequest(method, url);

    if (headers != null) request.headers.addAll(headers);
    if (fields != null) {
      for (final field in fields) {
        if (field.type == MultipartFieldType.media) {
          log('file ${field.name}', level: Level.FINER.value);
          final media = field.value as Media;
          request.files.add(await MultipartFile.fromPath('file', media.path));
        } else {
          request.fields[field.name] = field.value;
        }
      }
    }

    final ctName = '$method ${url.path}';
    var ct = cancellationTokens[ctName];
    if (cancelRunning && ct != null && !ct.isCancelled) {
      log('canceling request $ctName with token ${ct.hashCode}', level: Level.FINER.value);
      ct.cancel();
    }
    try {
      cancellationTokens[ctName] = CancellationToken();
      timeout ??= defaultTimeout;
      final req = send(request, cancellationToken: cancellationTokens[ctName]);
      final resp = timeout != null ? await req.timeout(timeout) : await req;
      cancellationTokens.remove(ctName);
      return _throwIfError(await Response.fromStream(resp));
    } on CancelledException {
      log('request $ctName canceled', level: Level.FINER.value);
      rethrow;
    }
  }

  Response _throwIfError(Response response) {
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return response;
    }
    if (errorHandler != null) {
      return errorHandler!.call(response);
    }
    ApiError error;
    final contentType = ContentType.parse(response.headers['content-type'] ?? '');
    if ([ContentType.json.mimeType, ContentTypeExt.errorJson.mimeType].contains(contentType.mimeType)) {
      final dynamic err = json.decodeBytes(response.bodyBytes);
      if (err is Map) {
        error = ApiError.fromJson(err as Map<String, dynamic>);
      } else {
        error = ApiError(status: response.statusCode, error: err.toString(), headers: response.headers);
      }
    } else if ([ContentType.html.mimeType, ContentType.text.mimeType].contains(contentType.mimeType)) {
      error = ApiError(status: response.statusCode, error: response.bodyBytes.toString(), headers: response.headers);
    } else {
      error = ApiError(status: response.statusCode, error: 'Unknown error', headers: response.headers);
    }
    final exception = ApiException(response.statusCode, response.reasonPhrase, error);
    errorLogger?.severe(exception, error, StackTrace.current);
    throw exception;
  }
}

void throwNotImplementedYet() {
  throw ApiException(500, 'Funkce nebyla implementována', ApiError(status: 500, error: 'Funkce nebyla implementována'));
}
