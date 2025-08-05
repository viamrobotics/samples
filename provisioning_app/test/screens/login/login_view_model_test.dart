import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provisioning_app/screens/login/login_view_model.dart';

import '../../mocks.mocks.dart';

void main() {
  late LoginViewModel loginViewModel;
  late MockViamAppRepository mockViamAppRepository;

  setUp(() {
    mockViamAppRepository = MockViamAppRepository();
    loginViewModel = LoginViewModel(viamAppRepository: mockViamAppRepository);
  });

  group('LoginViewModel', () {
    test('login should call loginAction', () async {
      await loginViewModel.login();

      verify(mockViamAppRepository.loginAction()).called(1);
    });
  });
}
