import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provisioning_app/auth/auth_service.dart';

import '../mocks.mocks.dart';

void main() {
  group('AuthService', () {
    late MockFlutterAppAuth mockAppAuth;
    late MockFlutterSecureStorage mockSecureStorage;
    late AuthService authService;

    const String refreshTokenKeyLiteral = 'refresh_token';

    setUp(() {
      mockAppAuth = MockFlutterAppAuth();
      mockSecureStorage = MockFlutterSecureStorage();
    });

    tearDown(() {
      reset(mockAppAuth);
      reset(mockSecureStorage);
    });

    test('init returns false when no refresh token is stored', () async {
      when(
        mockSecureStorage.read(key: anyNamed('key')),
      ).thenAnswer((_) async => null);
      authService = AuthService(
        appAuth: mockAppAuth,
        secureStorage: mockSecureStorage,
      );
      final result = await authService.init();

      expect(result, isFalse);
      verify(mockSecureStorage.read(key: refreshTokenKeyLiteral)).called(2);
      verifyNoMoreInteractions(mockAppAuth);
    });

    test(
      'init returns true and refreshes tokens if refresh token exists and tokens are invalid',
      () async {
        final dummyRefreshToken = 'some_refresh_token';
        when(
          mockSecureStorage.read(key: refreshTokenKeyLiteral),
        ).thenAnswer((_) async => dummyRefreshToken);

        final mockResponse = TokenResponse(
          'new_access_token',
          'new_refresh_token',
          DateTime.now().add(const Duration(hours: 1)),
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
          'Bearer',
          ['openid', 'profile', 'email', 'offline_access'],
          {},
        );

        when(
          mockAppAuth.token(argThat(isA<TokenRequest>())),
        ).thenAnswer((_) async => mockResponse);
        authService = AuthService(
          appAuth: mockAppAuth,
          secureStorage: mockSecureStorage,
        );
        final result = await authService.init();

        expect(result, isTrue);
        verify(mockSecureStorage.read(key: refreshTokenKeyLiteral)).called(2);
        verify(mockAppAuth.token(argThat(isA<TokenRequest>()))).called(2);
        verify(
          mockSecureStorage.write(
            key: refreshTokenKeyLiteral,
            value: 'new_refresh_token',
          ),
        ).called(2);
        expect(authService.isConnectionError, isFalse);
      },
    );

    test('loginAction successfully authorizes and exchanges code', () async {
      when(
        mockSecureStorage.read(key: anyNamed('key')),
      ).thenAnswer((_) async => null);
      final idTokenPayload = {
        'sub': 'user123',
        'given_name': 'John',
        'family_name': 'Doe',
        'email': 'john.doe@example.com',
        'picture': 'http://example.com/pic.jpg',
        'mobile_phone': null,
      };
      final encodedPayload = base64Url.encode(
        utf8.encode(jsonEncode(idTokenPayload)),
      );

      final mockAuthTokenResponse = AuthorizationTokenResponse(
        'test_access_token',
        'test_refresh_token',
        DateTime.now().add(const Duration(hours: 1)),
        'header.$encodedPayload.signature',
        'Bearer',
        ['openid', 'profile', 'email', 'offline_access'],
        {},
        {},
      );

      when(
        mockAppAuth.authorizeAndExchangeCode(
          argThat(isA<AuthorizationTokenRequest>()),
        ),
      ).thenAnswer((_) async => mockAuthTokenResponse);
      authService = AuthService(
        appAuth: mockAppAuth,
        secureStorage: mockSecureStorage,
      );

      await authService.loginAction();

      verify(mockAppAuth.authorizeAndExchangeCode(any)).called(1);

      expect(await authService.isLoggedIn, isTrue);
      expect(await authService.accessToken, isNotNull);
      expect((await authService.currentUser).sub, isNotNull);
      verify(
        mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).called(1);
    });

    // TODO: Add tests for logoutAction - currently tightly coupled with background task

    test('accessToken returns correct value when logged in', () async {
      final dummyRefreshToken = 'some_refresh_token';
      when(
        mockSecureStorage.read(key: refreshTokenKeyLiteral),
      ).thenAnswer((_) async => dummyRefreshToken);

      final mockLoginResponse = TokenResponse(
        'logged_in_token',
        'logged_in_refresh',
        DateTime.now().add(const Duration(hours: 1)),
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJsb2dnZWRfaW5fdXNlciIsIm5hbWUiOiJMb2dnZWQgSW4gVXNlciIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
        'Bearer',
        ['openid', 'profile', 'email', 'offline_access'],
        {},
      );
      when(
        mockAppAuth.token(argThat(isA<TokenRequest>())),
      ).thenAnswer((_) async => mockLoginResponse);
      authService = AuthService(
        appAuth: mockAppAuth,
        secureStorage: mockSecureStorage,
      );
      await authService.init();

      final token = await authService.accessToken;

      expect(token, 'logged_in_token');
    });

    test('currentUser returns correct user profile when logged in', () async {
      final dummyRefreshToken = 'some_refresh_token';
      when(
        mockSecureStorage.read(key: refreshTokenKeyLiteral),
      ).thenAnswer((_) async => dummyRefreshToken);

      final idTokenPayload = {
        'sub': 'logged_in_user',
        'given_name': 'Logged',
        'family_name': 'In',
        'email': 'logged.in@example.com',
      };
      final encodedPayload = base64Url.encode(
        utf8.encode(jsonEncode(idTokenPayload)),
      );

      final mockLoginResponse = TokenResponse(
        'logged_in_token',
        'logged_in_refresh',
        DateTime.now().add(const Duration(hours: 1)),
        'header.$encodedPayload.signature',
        'Bearer',
        ['openid', 'profile', 'email', 'offline_access'],
        {},
      );
      when(
        mockAppAuth.token(argThat(isA<TokenRequest>())),
      ).thenAnswer((_) async => mockLoginResponse);
      authService = AuthService(
        appAuth: mockAppAuth,
        secureStorage: mockSecureStorage,
      );
      await authService.init();

      final user = await authService.currentUser;

      expect(user.sub, 'logged_in_user');
      expect(user.givenName, 'Logged');
      expect(user.familyName, 'In');
      expect(user.email, 'logged.in@example.com');
    });

    test('isLoggedIn returns true when logged in', () async {
      final dummyRefreshToken = 'some_refresh_token';
      when(
        mockSecureStorage.read(key: refreshTokenKeyLiteral),
      ).thenAnswer((_) async => dummyRefreshToken);

      final mockLoginResponse = TokenResponse(
        'logged_in_token',
        'logged_in_refresh',
        DateTime.now().add(const Duration(hours: 1)),
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJsb2dnZWRfaW5fdXNlciIsIm5hbWUiOiJMb2dnZWQgSW4gVXNlciIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
        'Bearer',
        ['openid', 'profile', 'email', 'offline_access'],
        {},
      );
      when(
        mockAppAuth.token(argThat(isA<TokenRequest>())),
      ).thenAnswer((_) async => mockLoginResponse);
      authService = AuthService(
        appAuth: mockAppAuth,
        secureStorage: mockSecureStorage,
      );
      await authService.init();

      expect(await authService.isLoggedIn, isTrue);
    });

    test('isLoggedIn returns false when not logged in', () async {
      when(
        mockSecureStorage.read(key: anyNamed('key')),
      ).thenAnswer((_) async => null);
      authService = AuthService(
        appAuth: mockAppAuth,
        secureStorage: mockSecureStorage,
      );
      expect(await authService.isLoggedIn, isFalse);
    });
  });
}
