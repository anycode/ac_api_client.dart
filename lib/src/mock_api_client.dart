import 'dart:convert';

import 'package:ac_api_client/ac_api_client.dart';
import 'package:cancellation_token_http/testing.dart';

/// Function providing a JSON object or a JSON string with mocked response based on request.
/// Mocked JSON must contain at least two keys - `body` containing the actual response body
/// and `code` containing the HTTP response code. Optional key `headers` can contain additional
/// headers to be included in the response.
///
/// If there is an error inside the function, an [ApiException] or any other exception should be thrown.
typedef MockJsonProvider = Future<dynamic> Function(Request request);

/// Api client for testing purposes.
/// This API client extends HTTP API client with mock functionality and all HTTP API client logging methods.
/// It takes an optional constructor argument with a mock handler, which takes a request and returns a response.
///
/// If no own handler is provided, the default mock handler is used which will read mock data by [mockJsonProvider]
/// which must be then provided.
///
/// The default mock handler doesn't process the request headers, body or query parameters.
/// If you need to process them, you can do so in your mock handler. Signature is `Future<Response> handler(Request request)`.
class MockApiClient extends HttpApiClient {

  /// Function providing a JSON with mocked response based on request.
  /// See [MockJsonProvider] for more information. It's static so it can be
  /// used in static method [defaultMockHandler].
  static MockJsonProvider? _mockJsonProvider;

  MockApiClient({
    super.baseUri,
    MockClientHandler? mockHandler,
    MockJsonProvider? mockJsonProvider,
    super.uriBuilder,
    super.logOptions,
    super.headersOptions,
    super.retryOptions,
    super.logger,
    super.baseUrlLogger,
    super.retryLogger,
    super.headerLogger,
    super.performanceLogger,
    super.httpLogger,
    super.errorLogger,
    super.errorHandler,
    super.defaultTimeout = const Duration(minutes: 5),
  })  : assert(mockHandler != null || mockJsonProvider != null, 'Either mockHandler or mockJsonProvider must be specified'),
        super(inner: MockClient(mockHandler ?? defaultMockHandler)) {
    _mockJsonProvider = mockJsonProvider;
  }

  /// Default mock handler which reads mock data from [MockApiClient.mockJsonProvider].
  /// The response is expected to be a valid JSON object with at least two keys `body` and `code`.
  /// The `body` key is expected to contain the actual response body, and the `code` key is expected to contain the
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
