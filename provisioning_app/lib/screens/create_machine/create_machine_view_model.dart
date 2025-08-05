import 'package:flutter/material.dart';

import '../../data/repositories/viam_app_repository.dart';

class CreateMachineViewModel extends ChangeNotifier {
  final ViamAppRepository _viamAppRepository;

  CreateMachineViewModel({required ViamAppRepository viamAppRepository})
    : _viamAppRepository = viamAppRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _machineId;
  String? get machineId => _machineId;

  // TODO: replace with your own machine name schema.
  // A generic name for a machine.
  // Future developers can override this getter to provide a more specific name.
  // For example, a machine name could be the location name + a unique identifier.
  String get _machineName => 'my-machine';

  Future<void> createLocationAndMachine({required String locationName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orgId =
          _viamAppRepository.selectedOrg?.id ??
          (await _viamAppRepository.getSelectedOrg()).id;
      final location = await _viamAppRepository.createLocation(
        organizationId: orgId,
        name: locationName,
      );
      _machineId = await _viamAppRepository.newMachine(
        name: _machineName,
        locationId: location.id,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
