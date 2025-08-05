import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'auth/auth_service.dart';
import 'data/repositories/viam_app_repository.dart';
import 'data/services/shared_preferences_service.dart';
import 'routing/router.dart';
import 'theme/colors.dart';
import 'utils.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) => SharedPreferencesService(FlutterSecureStorage()),
        ),
        Provider(create: (context) => AuthService()),
        Provider(
          create:
              (context) => ViamAppRepository(
                authService: context.read(),
                sharedPreferencesService: context.read(),
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppInfo.setupInfo();
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: AppColors.colorScheme),
      routerConfig: router(),
    );
  }
}
