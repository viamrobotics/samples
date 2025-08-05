import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/viam_app_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final ViamAppRepository viamAppRepository;

  bool isLoading = true;
  bool loggingIn = false;
  bool needsUpdate = true;
  String? errorMessage;

  LoginViewModel({required this.viamAppRepository}) {
    initialize();
  }

  Future<void> clearRepoCache() async {
    await viamAppRepository.clearStoredVariables();
  }

  Future<void> initialize() async {
    await checkLoginState();
  }

  Future<bool> checkLoginState() async {
    try {
      final isLoggedIn = await viamAppRepository.checkLoginState();
      isLoading = false;
      notifyListeners();
      return isLoggedIn;
    } catch (e) {
      print(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login() async {
    loggingIn = true;
    errorMessage = null;
    notifyListeners();

    try {
      await viamAppRepository.loginAction();
      return true;
    } on PlatformException catch (e) {
      print(e);
      errorMessage = "Platform error: ${e.message}";
      return false;
    } catch (e) {
      errorMessage = "Error: $e";
      return false;
    } finally {
      loggingIn = false;
      notifyListeners();
    }
  }
}
