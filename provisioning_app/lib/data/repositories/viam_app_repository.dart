import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:viam_sdk/protos/app/app.dart';

import 'package:viam_sdk/viam_sdk.dart';

import '../../auth/auth_service.dart';
import '../services/shared_preferences_service.dart';

class ViamAppRepository {
  final AuthService _authService;
  final SharedPreferencesService _sharedPreferencesService;

  ViamAppRepository({
    required AuthService authService,
    required SharedPreferencesService sharedPreferencesService,
  }) : _authService = authService,
       _sharedPreferencesService = sharedPreferencesService {
    _init();
  }

  /// latest location sumaries, updated every 5 seconds, null if not initialized
  List<LocationSummary>? locationSummaries;
  Stream<List<LocationSummary>> get locationSummariesStream =>
      _locationSummariesStream.stream;
  final _locationSummariesStream =
      StreamController<List<LocationSummary>>.broadcast();

  Timer? _locationSummariesTimer;

  Organization? selectedOrg;
  Stream<Organization?> get selectedOrganizationStream =>
      _selectedOrganizationStream.stream;
  final _selectedOrganizationStream =
      StreamController<Organization?>.broadcast();

  final _log = Logger();

  bool get hasSelectedOrg => selectedOrg != null;
  Future<Viam> get viam async => await _authService.authenticatedViam;

  void dispose() {
    _locationSummariesTimer?.cancel();
    _locationSummariesStream.close();
  }

  Future<void> refresh() async {
    await _init();
  }

  Future<void> _init() async {
    // _log.d('[ViamAppRepository] initializing...');
    selectedOrg = await getSelectedOrg();

    // _log.d('[ViamAppRepository] initializing location summaries timer');
    _startTimer();
  }

  Future<void> updateMachineSummaries() async {
    final viam = await _authService.authenticatedViam;
    final summaries = await viam.appClient.listMachineSummaries(
      selectedOrg!.id,
    );
    locationSummaries = summaries;
    _locationSummariesStream.add(summaries);
  }

  void _startTimer() {
    updateMachineSummaries();
    // _log.d('[ViamAppRepository] initializing location summaries timer');
    _locationSummariesTimer ??= Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      await updateMachineSummaries();
    });
  }

  Future<Organization?> getStoredOrg() async {
    // _log.d('[ViamAppRepository] getStoredOrg');
    // if there is a selected org, use that.
    if (selectedOrg != null) {
      // _log.d('[ViamAppRepository] getStoredOrg: selected org already set');
      return selectedOrg!;
    }

    // If there is a most recent organization, use that.
    final userId = (await _authService.currentUser).sub;
    if (userId == null) {
      return null;
    }
    final mostRecentOrganizationId = await _sharedPreferencesService
        .getStoredOrg(userId);
    if (mostRecentOrganizationId != null) {
      // _log.d(
      // '[ViamAppRepository] getStoredOrg: most recent org found: $mostRecentOrganizationId',
      // );
      selectedOrg = await getOrganization(mostRecentOrganizationId);
      return selectedOrg!;
    }

    // _log.d('[ViamAppRepository] getStoredOrg: no org found');
    return null;
  }

  /// Gets the previously selected organization from shared preferences,
  /// or the first organization if no organization was previously selected.
  Future<Organization> getSelectedOrg() async {
    _log.d('[ViamAppRepository] getSelectedOrg');
    final storedOrg = await getStoredOrg();
    if (storedOrg != null) {
      _selectedOrganizationStream.add(selectedOrg);
      return storedOrg;
    }

    // _log.d('[ViamAppRepository] getSelectedOrg: no stored org found');
    // Otherwise, use the first organization that comes back
    selectedOrg = (await listOrganizations()).first;
    // _log.d(
    //   '[ViamAppRepository] getSelectedOrg: no stored org found, using first org: ${_selectedOrg!.id}',
    // );
    _selectedOrganizationStream.add(selectedOrg);
    return selectedOrg!;
  }

  Future<void> setSelectedOrg(Organization org) async {
    _log.d('[ViamAppRepository] setSelectedOrg: $org');
    final userId = (await _authService.currentUser).sub;
    if (userId != null) {
      _sharedPreferencesService.setSelectedOrg(userId, org.id);
    }
    selectedOrg = org;
    _selectedOrganizationStream.add(selectedOrg);
    _startTimer();
  }

  // Handles user change by clearing cache when user changes
  Future<void> clearStoredVariables() async {
    // User has changed, clear the cache
    selectedOrg = null;
  }

  Future<bool> checkLoginState() async {
    return _authService.init();
  }

  Future<void> loginAction() async {
    return _authService.loginAction();
  }

  // AppClient Wrappers

  Future<List<LocationSummary>> listMachineSummaries(
    String organizationId,
  ) async {
    // _log.d('[ViamAppRepository] listMachineSummaries: $organizationId');
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(
      () => viam.appClient.listMachineSummaries(organizationId),
    );
  }

  Future<Organization> getOrganization(String organizationId) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(
      () => viam.appClient.getOrganization(organizationId),
    );
  }

  Future<Robot> getRobot(String robotId) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(() => viam.appClient.getRobot(robotId));
  }

  Future<Location> getLocation(String locationId) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(() => viam.appClient.getLocation(locationId));
  }

  Future<List<Organization>> listOrganizations() async {
    // _log.d('[ViamAppRepository] listOrganizations');
    final viam = await _authService.authenticatedViam;
    // _log.d('[ViamAppRepository] got authenticated viam');
    return makeRequestWithRetry(() => viam.appClient.listOrganizations());
  }

  /// List all the [Location]s for the selected [Organization] or the provided [organizationId].
  Future<List<Location>> listLocations([String? organizationId]) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(
      () =>
          viam.appClient.listLocations(organizationId ?? selectedOrg?.id ?? ''),
    );
  }

  Future<List<Robot>> listRobots(String locationId) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(() => viam.appClient.listRobots(locationId));
  }

  Future<List<RobotPart>> listRobotParts(String robotId) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(() => viam.appClient.listRobotParts(robotId));
  }

  Future<void> updateRobotPart(
    String robotPartId,
    String name,
    Map<String, dynamic> config,
  ) async {
    final viam = await _authService.authenticatedViam;
    await makeRequestWithRetry(
      () => viam.appClient.updateRobotPart(robotPartId, name, config),
    );
  }

  Future<void> updateLocation({
    required String locationId,
    required String name,
  }) async {
    final viam = await _authService.authenticatedViam;
    await makeRequestWithRetry(
      () => viam.appClient.updateLocation(locationId, name: name),
    );
  }

  Future<void> deleteRobot(String robotId) async {
    final viam = await _authService.authenticatedViam;
    await makeRequestWithRetry(() => viam.appClient.deleteRobot(robotId));
  }

  Future<Location> createLocation({
    required String organizationId,
    required String name,
  }) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(
      () => viam.appClient.createLocation(organizationId, name),
    );
  }

  Future<void> log(
    String partId,
    String host,
    String loggerName,
    OutputEvent event,
  ) async {
    final viam = await _authService.authenticatedViam;
    await makeRequestWithRetry(
      () => viam.appRobotClient.log(partId, host, loggerName, event),
    );
  }

  /// Creates a new machine with the given name and inside the provided location ID.
  ///
  /// returns the robot ID of the new machine
  Future<String> newMachine({
    required String name,
    required String locationId,
  }) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(
      () => viam.appClient.newMachine(name, locationId),
    );
  }

  Future<({String token, String email})> getTokenAndEmail() async {
    final user = await _authService.currentUser;
    final email = user.email ?? '';
    final token = await _authService.accessToken;

    return (token: token, email: email);
  }

  Future<RobotPart> getRobotPart(String partId) async {
    final viam = await _authService.authenticatedViam;
    return makeRequestWithRetry(() => viam.appClient.getRobotPart(partId));
  }

  // RETRY LOGIC

  /// Make a gRPC request with retry logic
  ///
  /// This function will retry the request up to maxRetries times if it fails.
  /// It will use exponential backoff between retries.
  ///
  /// [request] is a function that returns a Future <`T`>
  /// [maxRetries] is the maximum number of retries, default is 3
  ///
  /// Returns the result of the request
  ///
  /// Throws an exception if the request fails after maxRetries attempts
  ///
  Future<T> makeRequestWithRetry<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    int delayMs = 500; // Initial delay

    while (attempt < maxRetries) {
      try {
        return await request();
      } on GrpcError catch (e) {
        if (!_shouldRetry(e) || attempt == maxRetries - 1) {
          rethrow; // If not retryable or out of attempts, throw the error
        }

        attempt++;
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // Exponential backoff
      }
    }

    throw Exception("Unexpected error: Max retries reached");
  }

  bool _shouldRetry(GrpcError e) {
    return [
      StatusCode.unavailable, // Server is unreachable or down
      StatusCode.deadlineExceeded, // Timeout
      StatusCode.resourceExhausted, // Rate-limited
    ].contains(e.code);
  }
}
