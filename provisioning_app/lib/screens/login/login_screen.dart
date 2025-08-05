import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../consts.dart';
import '../../routing/routes.dart';
import '../../utils.dart';
import '../webview.dart';
import 'login_view_model.dart';

class LoginScreen extends StatefulWidget {
  final LoginViewModel viewModel;
  final String? redirectTo;
  const LoginScreen({super.key, required this.viewModel, this.redirectTo});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (await widget.viewModel.checkLoginState()) {
      _routeToNext();
    }
  }

  /// routes user either to the LandingScreen or the path passed in from goRouter.
  void _routeToNext() async {
    if (widget.redirectTo != null) {
      context.go(widget.redirectTo!);
    } else {
      context.go(Routes.home);
    }
  }

  void _login() async {
    await widget.viewModel.clearRepoCache();

    final success = await widget.viewModel.login();
    if (success) {
      _routeToNext();
    } else if (widget.viewModel.errorMessage != null && mounted) {
      // Optionally show error dialog
      // showDialog<void>(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('Error logging in'),
      //       content: Text(widget.viewModel.errorMessage!),
      //     );
      //   },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          final viewModel = widget.viewModel;
          return viewModel.isLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    // TODO: replace with your own logo
                    child: Image.asset('images/logo-black.png'),
                  ),
                  SizedBox(height: 40),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: LinearBorder(),
                      minimumSize: Size(100, 56),
                    ),
                    onPressed: viewModel.loggingIn ? null : _login,
                    child: Text(
                      'Login',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.copyWith(color: Colors.white),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 100.0, right: 100.0),
                    child: Image.asset('images/powered-by-viam.png'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'By using this app, you agree to our\n',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const WebView(
                                              url: Urls.termsOfService,
                                              title: 'Terms of Service',
                                            ),
                                      ),
                                    );
                                  },
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const WebView(
                                              url: Urls.privacyPolicy,
                                              title: 'Privacy Policy',
                                            ),
                                      ),
                                    );
                                  },
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                  Text(AppInfo.version),
                  SizedBox(height: 36),
                ],
              );
        },
      ),
    );
  }
}
