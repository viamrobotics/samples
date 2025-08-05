import 'package:flutter/material.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';

import '../../data/repositories/viam_app_repository.dart';

class ProvisioningViewModel extends ChangeNotifier {
  ProvisioningViewModel({
    required ViamAppRepository viamAppRepository,
    required String machineId,
    required this.isNewMachine,
  }) {
    _viamAppRepository = viamAppRepository;
    _machineId = machineId;

    init();
  }

  late final ViamAppRepository _viamAppRepository;
  late final String _machineId;
  late final bool isNewMachine;

  bool loading = true;

  Robot? robot;
  RobotPart? mainPart;
  Viam? viam;

  dynamic error;

  Future<void> init() async {
    loading = true;
    notifyListeners();

    try {
      robot = await _viamAppRepository.getRobot(_machineId);
      final robotParts = await _viamAppRepository.listRobotParts(robot!.id);
      mainPart = robotParts.firstWhere((part) => part.mainPart);
      viam = await _viamAppRepository.viam;
      loading = false;
      notifyListeners();
    } catch (e) {
      error = e;
      loading = false;
      notifyListeners();
    }
  }
}
