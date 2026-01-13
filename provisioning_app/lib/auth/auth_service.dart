import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viam_sdk/viam_sdk.dart' hide Credentials;

class AuthService {
  AuthService({FlutterAppAuth? appAuth, FlutterSecureStorage? secureStorage})
    : appAuth = appAuth ?? FlutterAppAuth(),
      secureStorage =
          secureStorage ??
          FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            // This allows the the background task to access the secure storage even when the app is in the background
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
          ) {
    init();
  }

  FlutterAppAuth appAuth;
  FlutterSecureStorage secureStorage;

  // TODO REPLACE

  // Your Viam App Auth Client ID, you can get this from the Viam CLI.
  static const String authClientID = 'YOUR CLIENT ID';
  static const String _authLoginRedirectUri = 'YOUR APP BUNDLE ID://login-callback';
  static const String _authLogoutRedirectUri = 'YOUR APP BUNDLE ID://logout-callback';

  // You don't need to change these
  static const String _serviceHost = 'app.viam.com';
  static const String _domain = 'auth.viam.com';
  static const String _authIssuer = 'https://$_domain';
  static const String _audience = authClientID;

  String _refreshTokenKey = 'refresh_token';

  String? _userAccessToken;
  String? _userRefreshToken;
  DateTime? _accessTokenExpiration;
  String? _idToken;
  ViamUserProfile? _userProfile;
  bool isConnectionError = false;

  Future<bool> init() async {
    isConnectionError = false;

    _userRefreshToken ??= await secureStorage.read(key: _refreshTokenKey);

    if (_userRefreshToken == null) {
      return false;
    }

    try {
      if (!_validTokens()) await _refreshTokens;
      return true;
    } catch (e, s) {
      print('error on Refresh Token: $e - stack: $s');
      if (e.toString().contains("Connection error") || e.toString().contains("Network error")) {
        isConnectionError = true;
        return true;
      }
      // logOut() possibly
      return false;
    }
  }

  Future<void> loginAction() async {
    final result = await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        authClientID,
        _authLoginRedirectUri,
        issuer: _authIssuer,
        scopes: <String>['openid', 'profile', 'email', 'offline_access'],
        additionalParameters: {'audience': _audience},
      ),
    );

    await _setLocalVariables(result);
  }

  /// There is an assert in flutter_app_auth that will fail on debug builds when we try and log out
  /// In the package's EndSessionRequest class, comment out the assertion that requires both
  /// idTokenHint and postLogoutRedirectUrl to be null or non-null together.
  /// This is only needed for development as assertions are stripped in release mode.
  Future<void> logoutAction() async {
    await _clearLocalVariables();

    appAuth.endSession(
      EndSessionRequest(
        issuer: _authIssuer,
        postLogoutRedirectUrl: _authLogoutRedirectUri,
        additionalParameters: {'client_id': authClientID},
      ),
    );
  }

  Future<String> get accessToken async {
    if (!_validTokens() && _userRefreshToken != null) {
      await _refreshTokens;
    }

    if (_userAccessToken == null) {
      throw Exception('No access token available. User must log in.');
    }

    return _userAccessToken!;
  }

  Future<ViamUserProfile> get currentUser async {
    if (!_validTokens() && _userRefreshToken != null) {
      await _refreshTokens;
    }

    if (_userProfile == null) {
      throw Exception('No user profile available. User must log in.');
    }

    return _userProfile!;
  }

  Future<Viam> get authenticatedViam async {
    return Viam.withAccessToken(await accessToken, serviceHost: _serviceHost);
  }

  Future<bool> get isLoggedIn async {
    return _userAccessToken == null ? false : true;
  }

  bool _validTokens() {
    if (_userRefreshToken == null ||
        _userAccessToken == null ||
        _idToken == null ||
        _userProfile == null ||
        _accessTokenExpiration == null) {
      return false;
    }

    // check if the token is 1 minute or less away frome expiring
    if (_accessTokenExpiration!.isBefore(DateTime.now()..subtract(Duration(minutes: 1)))) {
      return false;
    }

    return true;
  }

  Future<TokenResponse> get _refreshTokens async {
    if (_userRefreshToken == null) {
      throw Exception('Cannot refresh tokens: no refresh token available');
    }

    try {
      final result = await appAuth.token(
        TokenRequest(
          authClientID,
          _authLoginRedirectUri,
          refreshToken: _userRefreshToken,
          additionalParameters: {'audience': _audience},
          issuer: _authIssuer,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
          grantType: 'refresh_token',
        ),
      );

      await _setLocalVariables(result);
      return result;
    } catch (e) {
      // _clearLocalVariables();

      throw Exception('Exception refreshing token: $e');
    }
  }

  _setLocalVariables(TokenResponse response) async {
    _userRefreshToken = response.refreshToken;
    _userAccessToken = response.accessToken;
    _idToken = response.idToken;
    _userProfile = ViamUserProfile.fromIdToken(_idToken!);
    _accessTokenExpiration = response.accessTokenExpirationDateTime;

    await secureStorage.write(key: _refreshTokenKey, value: _userRefreshToken);
  }

  _clearLocalVariables() async {
    _userRefreshToken = null;
    await secureStorage.delete(key: _refreshTokenKey);
    _userAccessToken = null;
    _idToken = null;
    _userProfile = null;
    _accessTokenExpiration = null;
  }
}

class ViamUserProfile {
  ViamUserProfile({
    required this.givenName,
    required this.familyName,
    required this.name,
    required this.email,
    required this.pictureUrl,
    required this.sub,
    required this.mobilePhone,
  });

  String? givenName;
  String? familyName;
  String? name;
  String? email;
  String? pictureUrl;
  String? sub;
  String? mobilePhone;

  factory ViamUserProfile.fromIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    final json = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final givenName = json['given_name'] ?? '';
    final familyName = json['family_name'] ?? '';
    final name = '$givenName $familyName';
    final email = json['email'];
    final pictureUrl = json['picture'];
    final sub = json['sub'];
    final mobilePhone = json['mobile_phone'];
    return ViamUserProfile(
      givenName: givenName,
      familyName: familyName,
      name: name,
      email: email,
      pictureUrl: pictureUrl,
      sub: sub,
      mobilePhone: mobilePhone,
    );
  }
}
