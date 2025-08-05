import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:viam_sdk/protos/app/app.dart';

import '../../auth/auth_service.dart';
import '../../routing/routes.dart';
import 'home_view_model.dart';
import 'widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});
  final HomeViewModel viewModel;

  void goToProvisioning(
    BuildContext context,
    String machineId,
    bool isNewMachine,
  ) {
    context.push(
      Routes.provisioning,
      extra: {'machineId': machineId, 'isNewMachine': isNewMachine},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),

        actions: [
          IconButton(
            onPressed: () => context.push(Routes.createMachine),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: MainMenuDrawer(
        homeViewModel: viewModel,
        authService: context.read<AuthService>(),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (viewModel.locationSummaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      context.push(Routes.createMachine);
                    },
                    label: Text("Add a machine"),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: viewModel.locationSummaries.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final location = viewModel.locationSummaries[index];
              return Column(
                children: [
                  for (MachineSummary machine in location.machineSummaries)
                    RobotListItem(
                      machineSummary: machine,
                      locationName: location.locationName,
                      onTap:
                          () => goToProvisioning(
                            context,
                            machine.machineId,
                            // TODO: check if machine is new
                            true,
                          ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
