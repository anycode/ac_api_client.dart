import 'dart:convert';
import 'dart:io';

import 'package:ac_dart/ac_dart.dart';
import 'package:cancellation_token_http/http.dart';
import 'package:cancellation_token_http/testing.dart';

import 'ac_api_client.dart';
import 'model/api_exception.dart';
import 'model/multipart.dart';

/// Function providing a JSON object or a JSON string with mocked response based on request.
/// Mocked JSON must contain at least two keys - `body` containing the actual response body
/// and `code` containing the HTTP response code. Optional key `headers` can contain additional
/// headers to be included in the response.
///
/// If there is an error inside the function, an [ApiException] or any other exception should be thrown.
typedef MockJsonProvider = Future<dynamic> Function(Request request);

/// Api client for testing purposes.
///
/// Deprecated: Use MockApiClient instead, which offers the same functionality and adds functionality of HttpApiClient with all logging methods.
///
/// This API client implements API client with mock functionality. It takes an optional constructor argument with a mock handler,
/// which takes a request and returns a response. It's possible to pass a `baseUri` and `uriBuilder` to the constructor.
///
/// The default mock handler reads mock data from assets folder from path `assets/mock/responses/${request.url.host}/${request.url.path}.json`.
/// Slashes in the path are replaced with dashes. The default mock handler doesn't process the request headers, body or query parameters.
/// If you need to process them, you can do so in your mock handler. Signature is `Future<Response> handler(Request request)`.
///
/// E.g. request url `https://example.com/api/v1/user` will read mock data from `assets/mock/responses/example.com/api-v1-user.json`.
@Deprecated('Use MockApiClient instead')
class MockApiClientDeprecated extends AcApiClient {
  /// Mock client handler to handle requests and return responses.
  final MockClientHandler mockClientHandler;

  /// Function providing a JSON with mocked response based on request.
  /// See [MockJsonProvider] for more information. It's static so it can be
  /// used in static method [defaultMockHandler].
  static MockJsonProvider? _mockJsonProvider;


  /// Creates a mock API client with optional mock client handler. If no handler is provided, the default mock handler is used.
  MockApiClientDeprecated({
    super.baseUri,
    super.uriBuilder,
    super.defaultContentType,
    MockClientHandler? mockHandler,
    MockJsonProvider? mockJsonProvider,
  })  : assert(mockHandler != null || mockJsonProvider != null, 'Either mockHandler or mockJsonProvider must be specified'),
        mockClientHandler = mockHandler ?? defaultMockHandler;

  /// Mocked GET method to read data
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
    return mockClientHandler(
      buildRequest(
        'GET',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        defaultContentType: defaultContentType,
      ),
    );
  }

  /// Mocked POST method to post data and read response
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
    return mockClientHandler(
      buildRequest(
        'POST',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        encoding: encoding,
        body: body,
        defaultContentType: defaultContentType,
      ),
    );
  }

  @override
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
    return mockClientHandler(
      buildRequest(
        'POST',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        fields: fields,
        defaultContentType: defaultContentType,
      ),
    );
  }

  /// Mocked PUT method to put data
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
    return mockClientHandler(
      buildRequest(
        'PUT',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        encoding: encoding,
        body: body,
        defaultContentType: defaultContentType,
      ),
    );
  }

  @override
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
    return mockClientHandler(
      buildRequest(
        'PUT',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        fields: fields,
        defaultContentType: defaultContentType,
      ),
    );
  }

  /// Mocked PATCH method to patch data
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
    return mockClientHandler(
      buildRequest(
        'PATCH',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        encoding: encoding,
        body: body,
        defaultContentType: defaultContentType,
      ),
    );
  }

  @override
  Future<Response> patchMultipart(
    path, {
    String? host,
    String? url,
    Map<String, String>? headers,
    List<MultipartField>? fields,
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool cancelRunning = false,
  }) {
    return mockClientHandler(
      buildRequest(
        'PATCH',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        fields: fields,
        defaultContentType: defaultContentType,
      ),
    );
  }

  /// Mocked DELETE method to delete data
  @override
  Future<Response> delete(
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
    return mockClientHandler(
      buildRequest(
        'DELETE',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        body: body,
        defaultContentType: defaultContentType,
      ),
    );
  }

  @override
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
  }) {
    return mockClientHandler(
      buildRequest(
        'EXEC',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        body: body,
        encoding: encoding,
        headers: headers,
        defaultContentType: defaultContentType,
      ),
    );
  }

  @override
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
  }) {
    return mockClientHandler(
      buildRequest(
        'PURGE',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        body: body,
        encoding: encoding,
        headers: headers,
        defaultContentType: defaultContentType,
      ),
    );
  }

  @override
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
  }) {
    return mockClientHandler(
      buildRequest(
        'RESET',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        body: body,
        encoding: encoding,
        headers: headers,
        defaultContentType: defaultContentType,
      ),
    );
  }

  @override
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
  }) {
    return mockClientHandler(
      buildRequest(
        'LOCK',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        body: body,
        encoding: encoding,
        headers: headers,
        defaultContentType: defaultContentType,
      ),
    );
  }

  @override
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
  }) {
    return mockClientHandler(
      buildRequest(
        'UNLOCK',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        body: body,
        encoding: encoding,
        headers: headers,
        defaultContentType: defaultContentType,
      ),
    );
  }

  /// Method to build a request from parameters
  static Request buildRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    body,
    Encoding? encoding,
    Duration? timeout,
    List<MultipartField>? fields,
    required ContentType defaultContentType,
  }) {
    final request = Request(method, url);

    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    final contentType = request.headers['content-type'] ?? defaultContentType.value;
    if (body != null) {
      if (body is String) {
        // raw body already as a string
        request.body = body;
      } else if (body is List<int>) {
        // raw body already as a list of bytes
        request.bodyBytes = body;
      } else if (body is List) {
        // list of other types - encode as json or stringify
        if ([ContentType.json.value, ContentTypeExt.errorJson.value].contains(contentType)) {
          request.body = json.encode(body);
        } else {
          request.body = body.toString();
        }
      } else if (body is Map) {
        // map of objects - encode as json or form data or stringify
        if ([ContentType.json.value, ContentTypeExt.errorJson.value].contains(contentType)) {
          request.body = json.encode(body);
        } else if (ContentTypeExt.formUrlEncoded.value == contentType) {
          request.bodyFields = body.cast<String, String>();
        } else if (ContentTypeExt.formData.value == contentType) {
          request.body = body.entries.map((entry) => '${entry.key}=${entry.value}').join('&');
        } else {
          request.body = body.toString();
        }
      } else if (ContentType.json.value == contentType) {
        // other types - encode as json
        request.body = json.encode(body);
      } else {
        // unknown body type
        throw ArgumentError('Invalid request body "$body".');
      }
    }
    return request;
  }

  /// Default mock handler which reads mock data from assets folder. The response is expected to be a valid JSON object with at least two
  /// keys `body` and `code`. The `body` key is expected to contain the actual response body, and the `code` key is expected to contain the
  /// HTTP response code. The `headers` key is optional and can contain additional headers to be included in the response.
  /// If there is an error (missing or invalid JSON), an error response is returned.
  static Future<Response> defaultMockHandler(Request request) async {
    dynamic mock;
    try {
      mock = await _mockJsonProvider!(request);
    } on ApiException catch (e) {
      return Response('MOCK ERROR', e.code, reasonPhrase: e.reason);
    } catch (e) {
      return Response('MOCK ERROR', 500, reasonPhrase: 'Generic error with mock ${request.url.host}/${request.url.path}');
    }
    Map<String, dynamic> json;
    if (mock is String) {
      try {
        json = jsonDecode(mock);
      } catch (e) {
        return Response('MOCK INVALID JSON', 500,
            reasonPhrase: 'Mock for ${request.url.host}/${request.url.path} is not valid JSON string: $mock');
      }
    } else if (mock is Map<String, dynamic>) {
      json = mock;
    } else {
      return Response('MOCK INVALID JSON', 500,
          reasonPhrase: 'Mock for ${request.url.host}/${request.url.path} must be a string or a map: $mock');
    }
    if (json.containsKey('body') && json.containsKey('code')) {
      return Response(jsonEncode(json['body']), json['code'],
          headers: json['headers'] ?? <String, String>{'Content-Type': 'application/json'});
    } else {
      return Response('MOCK INVALID JSON', 500,
          reasonPhrase: 'Mock JSON for ${request.url.host}/${request.url.path} does not contain keys `body` and `code`: $mock');
    }
  }
}
