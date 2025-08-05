import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viam_sdk/protos/app/app.dart';

import '../../routing/routes.dart';
import 'org_picker_view_model.dart';

class OrgPickerScreen extends StatelessWidget {
  const OrgPickerScreen({super.key, required this.viewModel});

  final OrgPickerViewModel viewModel;

  void onSelectOrg(BuildContext context, Organization org) {
    viewModel.onSelectOrg(org);
    context.go(Routes.home);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Select Organization')),
          body:
              viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: viewModel.organizations.length,
                    itemBuilder: (context, index) {
                      final org = viewModel.organizations[index];
                      return ListTile(
                        title: Text(org.name),
                        onTap: () => onSelectOrg(context, org),
                        selected: viewModel.selectedOrg?.id == org.id,
                      );
                    },
                  ),
        );
      },
    );
  }
}
