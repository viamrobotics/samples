import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provisioning_app/data/services/shared_preferences_service.dart';

import '../mocks.mocks.dart';

void main() {
  late SharedPreferencesService sharedPreferencesService;
  late MockFlutterSecureStorage mockFlutterSecureStorage;

  setUp(() {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    sharedPreferencesService = SharedPreferencesService(
      mockFlutterSecureStorage,
    );
  });

  group('SharedPreferencesService', () {
    test('should return stored org when it exists', () async {
      when(
        mockFlutterSecureStorage.read(key: 'user-123.org'),
      ).thenAnswer((_) async => 'org-123');
      final result = await sharedPreferencesService.getStoredOrg('user-123');
      expect(result, 'org-123');
    });

    test('should return null when org does not exist', () async {
      when(
        mockFlutterSecureStorage.read(key: anyNamed('key')),
      ).thenAnswer((_) async => null);
      final result = await sharedPreferencesService.getStoredOrg('user-123');
      expect(result, isNull);
    });

    test('should call write on set selected org', () async {
      await sharedPreferencesService.setSelectedOrg('user-123', 'org-123');
      verify(
        mockFlutterSecureStorage.write(key: 'user-123.org', value: 'org-123'),
      );
    });
  });
}
