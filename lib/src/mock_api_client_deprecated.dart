import 'dart:convert';
import 'dart:io';

import 'package:ac_dart/ac_dart.dart';
import 'package:cancellation_token_http/http.dart';
import 'package:cancellation_token_http/testing.dart';
import 'package:flutter/services.dart';

import 'ac_api_client.dart';

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
  MockClientHandler mockClientHandler;

  /// Creates a mock API client with optional mock client handler. If no handler is provided, the default mock handler is used.
  MockApiClientDeprecated({super.baseUri, super.uriBuilder, this.mockClientHandler = defaultMockHandler});

  /// Mocked GET method to read data
  @override
  Future<Response> get(String path, {String? host, String? url, Map<String, String>? headers, Map<String, dynamic>? queryParameters}) {
    return mockClientHandler(
      buildRequest(
        'GET',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
      ),
    );
  }

  /// Mocked POST method to post data and read response
  @override
  Future<Response> post(String path,
      {String? host, String? url, Map<String, String>? headers, body, Encoding? encoding, Map<String, String>? queryParameters}) {
    return mockClientHandler(
      buildRequest(
        'POST',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        encoding: encoding,
        body: body,
      ),
    );
  }

  /// Mocked PUT method to put data
  @override
  Future<Response> put(String path,
      {String? host, String? url, Map<String, String>? headers, body, Encoding? encoding, Map<String, String>? queryParameters}) {
    return mockClientHandler(
      buildRequest(
        'PUT',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        encoding: encoding,
        body: body,
      ),
    );
  }

  /// Mocked PATCH method to patch data
  @override
  Future<Response> patch(String path,
      {String? host, String? url, Map<String, String>? headers, body, Encoding? encoding, Map<String, String>? queryParameters}) {
    return mockClientHandler(
      buildRequest(
        'PATCH',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        encoding: encoding,
        body: body,
      ),
    );
  }

  /// Mocked DELETE method to delete data
  @override
  Future<Response> delete(String path,
      {String? host, String? url, Map<String, String>? headers, dynamic body, Map<String, String>? queryParameters}) async {
    return mockClientHandler(
      buildRequest(
        'DELETE',
        uriBuilder(url: url, host: host, path: path, queryParameters: queryParameters),
        headers: headers,
        body: body,
      ),
    );
  }

  /// Method to build a request from parameters
  static Request buildRequest(String method, Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, Duration? timeout}) {
    final request = Request(method, url);

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
    return request;
  }

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
