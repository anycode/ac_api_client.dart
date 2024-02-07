import 'dart:convert';

import 'package:ac_http_client/ac_http_client.dart';
import 'package:cancellation_token_http/testing.dart';
import 'package:flutter/services.dart';

/// Api client for testing purposes.
/// This API client extends HTTP API client with mock functionality and all HTTP API client logging methods.
/// It takes an optional constructor argument with a mock handler, which takes a request and returns a response.
///
/// The default mock handler reads mock data from assets folder from path `assets/mock/responses/${request.url.host}/${request.url.path}.json`.
/// Slashes in the path are replaced with dashes. The default mock handler doesn't process the request headers, body or query parameters.
/// If you need to process them, you can do so in your mock handler. Signature is `Future<Response> handler(Request request)`.
/// 
/// E.g. request url `https://example.com/api/v1/user` will read mock data from `assets/mock/responses/example.com/api-v1-user.json`.
class MockApiClient extends HttpApiClient {
  MockApiClient({
    super.baseUri,
    MockClientHandler mockHandler = defaultMockHandler,
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
  }) : super(inner: MockClient(mockHandler));

  /// Default mock handler which reads mock data from assets folder. The response is expected to be a valid JSON object with at least two
  /// keys `body` and `code`. The `body` key is expected to contain the actual response body, and the `code` key is expected to contain the
  /// HTTP response code. The `headers` key is optional and can contain additional headers to be included in the response.
  /// If there is an error (missing or invalid JSON), an error response is returned. 
  static Future<Response> defaultMockHandler(Request request) async {
    try {
      final mock = await rootBundle.loadString('assets/mock/responses/${request.url.host}/${request.url.path.replaceAll('/', '-')}.json');
      dynamic json;
      try {
        json = jsonDecode(mock);
      } catch (e) {
        return Response('MOCK INVALID JSON', 500, reasonPhrase: 'Mock ${request.url.host}/${request.url.path} is not valid json: $mock');
      }
      if (json is Map && json.containsKey('body') && json.containsKey('code')) {
        return Response(jsonEncode(json['body']), json['code'],
            headers: json['headers'] ?? <String, String>{'Content-Type': 'application/json'});
      } else {
        throw Exception('Invalid MOCK JSON on path ${request.url.host}/${request.url.path}');
      }
    } catch (e) {
      return Response('MOCK FILE NOT FOUND', 404, reasonPhrase: 'Mock ${request.url.host}/${request.url.path} not found');
    }
  }

}
