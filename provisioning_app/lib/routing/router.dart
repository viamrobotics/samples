import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../screens/create_machine/create_machine.dart';
import '../screens/home/home.dart';
import '../screens/login/login.dart';
import '../screens/provisioning/provisioning.dart';
import 'routes.dart';

/// Top go_router entry point.
///
/// Listens to changes in [AuthService] to redirect the user
/// to /login when the user logs out.
GoRouter router() => GoRouter(
  initialLocation: Routes.login,
  debugLogDiagnostics: true,
  redirect: _redirect,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        return LoginScreen(
          viewModel: LoginViewModel(viamAppRepository: context.read()),
        );
      },
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        final viewModel = HomeViewModel(viamAppRepository: context.read());
        viewModel.viamAppRepository.refresh();
        return HomeScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.provisioning,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        final viewModel = ProvisioningViewModel(
          viamAppRepository: context.read(),
          machineId: args['machineId'] as String,
          isNewMachine: args['isNewMachine'] as bool,
        );
        return ProvisioningScreen(provisioningViewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.createMachine,
      builder: (context, state) {
        return CreateMachineScreen(
          viewModel: CreateMachineViewModel(viamAppRepository: context.read()),
        );
      },
    ),
  ],
);

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // if the user is not logged in, they need to login
  final loggedIn = await context.read<AuthService>().isLoggedIn;
  if (!loggedIn) {
    return Routes.login;
  }

  // if the user is logged in but still on the login page, send them to
  // the home page
  if (state.matchedLocation == Routes.login && loggedIn) {
    return Routes.home;
  }

  // no need to redirect at all
  return null;
}
