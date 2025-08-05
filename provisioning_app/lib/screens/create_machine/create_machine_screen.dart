import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';
import '../../theme/colors.dart';
import 'create_machine_view_model.dart';

class CreateMachineScreen extends StatefulWidget {
  final CreateMachineViewModel viewModel;

  const CreateMachineScreen({super.key, required this.viewModel});

  @override
  State<CreateMachineScreen> createState() => _CreateMachineScreenState();
}

class _CreateMachineScreenState extends State<CreateMachineScreen> {
  final TextEditingController _locationNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    super.dispose();
  }

  void _createMachine() async {
    await widget.viewModel.createLocationAndMachine(
      locationName: _locationNameController.text,
    );

    if (widget.viewModel.errorMessage == null && mounted) {
      context.replace(
        Routes.provisioning,
        extra: {'machineId': widget.viewModel.machineId, 'isNewMachine': true},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Machine')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    autofocus: true,
                    controller: _locationNameController,
                    decoration: const InputDecoration(
                      labelText: 'Location Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.viewModel.isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed:
                          _locationNameController.text.isEmpty
                              ? null
                              : _createMachine,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create'),
                    ),
                  if (widget.viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
