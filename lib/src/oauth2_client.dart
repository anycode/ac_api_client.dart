import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'model/api_exception.dart';
import 'oauth2_login_credentials.dart';
import 'package:cancellation_token_http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

abstract interface class OAuth2ServiceProvider {
  bool get hasOAuthCredentials;
  oauth2.Credentials? get oAuthCredentials;
  set oAuthCredentials(oauth2.Credentials? credentials);

  bool get hasLoginCredentials;
  LoginCredentials? get loginCredentials;
  set loginCredentials(LoginCredentials? credentials);
}

class OAuth2Client extends BaseClient {
  final Client inner;
  final String oAuthIdentifier;
  final String oAuthSecret;
  final List<String> oAuthScopes;
  final Uri oAuthAuthorizationUri;
  final OAuth2ServiceProvider oAuthServiceProvider;

  Client? _client;

  OAuth2Client({
    required this.oAuthAuthorizationUri,
    required this.oAuthIdentifier,
    required this.oAuthSecret,
    required this.oAuthScopes,
    required this.oAuthServiceProvider,
    required this.inner,
  });

  @override
  Future<StreamedResponse> send(
    BaseRequest request, {
    CancellationToken? cancellationToken,
  }) async {
    if (_client == null || _client is oauth2.Client && !oAuthServiceProvider.hasOAuthCredentials) {
      // jeste nemam HTTP clienta, nebo mam oAuth klienta bez OAuth credentials, vytvorim obyc klienta
      _client = inner;
    }
    if (_client is! oauth2.Client && (oAuthServiceProvider.hasOAuthCredentials || oAuthServiceProvider.hasLoginCredentials)) {
      // mam prihlasovaci udaje (jmeno a heslo nebo token), obalim HTTP klienta do OAuth
      oauth2.Client oauthClient;
      if (oAuthServiceProvider.hasOAuthCredentials) {
        // mam tokeny
        oauthClient =
            oauth2.Client(oAuthServiceProvider.oAuthCredentials!, identifier: oAuthIdentifier, secret: oAuthSecret, httpClient: inner);
      } else {
        // mam jmeno a heslo
        try {
          oauthClient = await oauth2.resourceOwnerPasswordGrant(
              oAuthAuthorizationUri, oAuthServiceProvider.loginCredentials!.username, oAuthServiceProvider.loginCredentials!.password,
              identifier: oAuthIdentifier,
              secret: oAuthSecret,
              scopes: oAuthScopes,
              cancellationToken: cancellationToken,
              httpClient: inner);
          oAuthServiceProvider.oAuthCredentials = oauthClient.credentials;
        } on SocketException {
          oAuthServiceProvider.oAuthCredentials = null;
          rethrow;
        } catch (e) {
          oAuthServiceProvider.oAuthCredentials = null;
          throw ApiException(400, e.toString(), null);
        }
      }
      _client = oauthClient;
    }
    // nastavim basic autorizaci, pokud je http klient OAuth2, prepise se autorizace v
    // oauth2.Client.send()
    request.headers['authorization'] = 'Basic ${base64.encode(utf8.encode('$oAuthIdentifier:$oAuthSecret'))}';
    return _client!.send(request, cancellationToken: cancellationToken);
  }

  @override
  void close() {
    _client?.close();
    _client = null;
  }
}
