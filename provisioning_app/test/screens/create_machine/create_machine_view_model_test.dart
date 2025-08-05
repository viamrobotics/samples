import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provisioning_app/screens/create_machine/create_machine_view_model.dart';
import 'package:viam_sdk/src/gen/app/v1/app.pb.dart';

import '../../mocks.mocks.dart';

void main() {
  late CreateMachineViewModel createMachineViewModel;
  late MockViamAppRepository mockViamAppRepository;

  setUp(() {
    mockViamAppRepository = MockViamAppRepository();
    createMachineViewModel = CreateMachineViewModel(
      viamAppRepository: mockViamAppRepository,
    );
  });

  group('CreateMachineViewModel', () {
    test(
      'createLocationAndMachine should set error message on failure',
      () async {
        when(
          mockViamAppRepository.createLocation(
            organizationId: anyNamed('organizationId'),
            name: anyNamed('name'),
          ),
        ).thenThrow(Exception('Failed to create location'));
        when(mockViamAppRepository.getSelectedOrg()).thenAnswer(
          (_) async => Organization(id: 'org-123', name: 'test-org'),
        );

        await createMachineViewModel.createLocationAndMachine(
          locationName: 'test-location',
        );

        expect(createMachineViewModel.machineId, isNull);
        expect(createMachineViewModel.errorMessage, isNotNull);
        expect(createMachineViewModel.isLoading, isFalse);
      },
    );
  });
}
