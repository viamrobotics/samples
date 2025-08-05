import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:provisioning_app/auth/auth_service.dart';
import 'package:provisioning_app/data/repositories/viam_app_repository.dart';
import 'package:provisioning_app/data/services/shared_preferences_service.dart';
import 'package:viam_sdk/src/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';

@GenerateMocks([
  AppClient,
  AuthService,
  FlutterAppAuth,
  FlutterSecureStorage,
  SharedPreferencesService,
  Viam,
  ViamAppRepository,
])
void main() {}
