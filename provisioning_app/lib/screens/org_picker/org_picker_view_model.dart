import 'package:flutter/material.dart';
import 'package:viam_sdk/protos/app/app.dart';

import '../../data/repositories/viam_app_repository.dart';

class OrgPickerViewModel extends ChangeNotifier {
  final ViamAppRepository viamAppRepository;

  OrgPickerViewModel({required this.viamAppRepository}) {
    initialize();
  }

  List<Organization> organizations = [];
  Organization? selectedOrg;
  bool isLoading = true;

  Future<void> initialize() async {
    organizations = await viamAppRepository.listOrganizations();
    selectedOrg = viamAppRepository.selectedOrg;
    isLoading = false;
    notifyListeners();
  }

  void onSelectOrg(Organization org) {
    viamAppRepository.setSelectedOrg(org);
    selectedOrg = org;
    notifyListeners();
  }
}
