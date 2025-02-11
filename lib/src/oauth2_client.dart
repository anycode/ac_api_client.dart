import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cancellation_token_http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

import 'model/api_exception.dart';
import 'oauth2_login_credentials.dart';

abstract interface class OAuth2ServiceProvider {
  bool get hasOAuthCredentials;
  oauth2.Credentials? get oAuthCredentials;
  set oAuthCredentials(oauth2.Credentials? credentials);

  bool get hasLoginCredentials;
  LoginCredentials? get loginCredentials;
  set loginCredentials(LoginCredentials? credentials);

  String get oAuthIdentifier;
  String get oAuthSecret;
  List<String> get oAuthScopes;
  Uri get oAuthAuthorizationUri;
}

class OAuth2Client extends BaseClient {
  final Client inner;
  final OAuth2ServiceProvider oAuthServiceProvider;

  Client? _client;

  OAuth2Client({
    required this.oAuthServiceProvider,
    required this.inner,
  });

  @override
  Future<StreamedResponse> send(
    BaseRequest request, {
    CancellationToken? cancellationToken,
  }) async {
    if (_client == null || _client is oauth2.Client && !oAuthServiceProvider.hasOAuthCredentials) {
      // no HTTP client yet, or OAuth2 client without OAuth credentials, simply use inner HTTP client
      _client = inner;
    }
    if (_client is! oauth2.Client && (oAuthServiceProvider.hasOAuthCredentials || oAuthServiceProvider.hasLoginCredentials)) {
      // We already have login credentials (username and password or token), wrap inner HTTP client into OAuth2 client
      oauth2.Client oauthClient;
      if (oAuthServiceProvider.hasOAuthCredentials) {
        // We've got token
        oauthClient = oauth2.Client(
          oAuthServiceProvider.oAuthCredentials!,
          identifier: oAuthServiceProvider.oAuthIdentifier,
          secret: oAuthServiceProvider.oAuthSecret,
          httpClient: inner,
        );
      } else {
        // We've got username and password
        try {
          oauthClient = await oauth2.resourceOwnerPasswordGrant(
            oAuthServiceProvider.oAuthAuthorizationUri,
            oAuthServiceProvider.loginCredentials!.username,
            oAuthServiceProvider.loginCredentials!.password,
            identifier: oAuthServiceProvider.oAuthIdentifier,
            secret: oAuthServiceProvider.oAuthSecret,
            scopes: oAuthServiceProvider.oAuthScopes,
            cancellationToken: cancellationToken,
            httpClient: inner,
          );
          oAuthServiceProvider.oAuthCredentials = oauthClient.credentials;
        } on SocketException {
          oAuthServiceProvider.oAuthCredentials = null;
          rethrow;
        } catch (e) {
          oAuthServiceProvider.oAuthCredentials = null;
          throw ApiException(400, e.toString(), null, null);
        }
      }
      _client = oauthClient;
    }
    // Set basic authorization
    // If the HTTP client is OAuth2, the authorization will be reset in oauth2.Client.send()
    request.headers['authorization'] =
        'Basic ${base64.encode(utf8.encode('${oAuthServiceProvider.oAuthIdentifier}:${oAuthServiceProvider.oAuthSecret}'))}';
    return _client!.send(request, cancellationToken: cancellationToken);
  }

  @override
  void close() {
    _client?.close();
    _client = null;
  }
}
