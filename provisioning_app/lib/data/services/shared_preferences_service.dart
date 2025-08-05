import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPreferencesService {
  final FlutterSecureStorage _storage;

  SharedPreferencesService(this._storage);

  Future<String?> getStoredOrg(String userId) async {
    return _storage.read(key: '$userId.org');
  }

  Future<void> setSelectedOrg(String userId, String orgId) async {
    await _storage.write(key: '$userId.org', value: orgId);
  }
}
