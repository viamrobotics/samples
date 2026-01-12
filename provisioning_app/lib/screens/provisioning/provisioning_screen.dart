import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viam_flutter_bluetooth_provisioning_widget/viam_flutter_bluetooth_provisioning_widget.dart';

import '../../routing/routes.dart';
import 'provisioning_view_model.dart';

class ProvisioningScreen extends StatelessWidget {
  const ProvisioningScreen({super.key, required this.provisioningViewModel});

  final ProvisioningViewModel provisioningViewModel;

  void goToHome(BuildContext context) {
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provisioningViewModel,
      builder: (context, child) {
        if (provisioningViewModel.loading) {
          return Scaffold(appBar: AppBar(title: const Text('Setup')), body: const Center(child: CircularProgressIndicator()));
        }
        if (provisioningViewModel.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Setup')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error),
                  const SizedBox(height: 16),
                  Text('There was an error provisioning your machine.'),
                  const SizedBox(height: 16),
                  Text(provisioningViewModel.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => provisioningViewModel.init(), child: const Text('Try again')),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => goToHome(context), child: const Text('Go to home')),
                ],
              ),
            ),
          );
        }
        return BluetoothProvisioningFlow(
          viam: provisioningViewModel.viam,
          robot: provisioningViewModel.robot,
          isNewMachine: true,
          mainRobotPart: provisioningViewModel.mainPart,
          psk: 'viamsetup',
          fragmentId: null,
          agentMinimumVersion: '0.20.0',
          copy: BluetoothProvisioningFlowCopy(),
          onSuccess: () => goToHome(context),
          existingMachineExit: () => goToHome(context),
          nonexistentMachineExit: () => goToHome(context),
          agentMinimumVersionExit: () => goToHome(context),
        );
      },
    );
  }
}
