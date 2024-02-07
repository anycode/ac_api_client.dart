class LoginCredentials {
  final String _username;
  final String _password;

  LoginCredentials(this._username, this._password);

  String get username => _username;

  String get password => _password;

  bool get isValid => (_username.isNotEmpty) && (_password.isNotEmpty);
}
