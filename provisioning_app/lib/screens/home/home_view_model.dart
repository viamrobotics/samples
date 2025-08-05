import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'package:viam_sdk/protos/app/app.dart';

import '../../data/repositories/viam_app_repository.dart';
import '../org_picker/org_picker.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.viamAppRepository}) {
    locationSummaries = viamAppRepository.locationSummaries ?? [];
    viamAppRepository.locationSummariesStream.listen((value) {
      // _log.d('[HomeViewModel] _init: got location summaries stream update');
      final sorted =
          value.toList()
            ..sort((a, b) => a.locationName.compareTo(b.locationName));
      locationSummaries = sorted;
      isLoading = false;
      notifyListeners();
    });

    selectedOrg = viamAppRepository.selectedOrg;
    viamAppRepository.selectedOrganizationStream.listen((value) {
      // _log.d('[HomeViewModel] _init: got selected organization stream update');
      selectedOrg = value;
      isLoading = true;
      notifyListeners();
    });
  }

  final ViamAppRepository viamAppRepository;
  // final _log = Logger();

  bool isLoading = true;
  List<LocationSummary> locationSummaries = [];
  Organization? selectedOrg;

  void onChangeOrgPressed(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (context) => OrgPickerScreen(
              viewModel: OrgPickerViewModel(
                viamAppRepository: viamAppRepository,
              ),
            ),
      ),
    );
  }
}
