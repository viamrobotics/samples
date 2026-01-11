import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'consts.dart';
import 'screens/webview.dart';

Future<void> showLogoutDialog(
  BuildContext context,
  AsyncCallback logoutCallback,
) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return PlatformAlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          PlatformDialogAction(
            child: Text('Yes', style: TextStyle(color: Colors.blueAccent)),
            onPressed: () async {
              await logoutCallback();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          PlatformDialogAction(
            child: Text('No', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// Show an error dialog with one action: OK, which simply dismisses the dialog
Future<void> showErrorDialog(
  BuildContext context, {
  String title = 'An Error Occurred',
  String? error,
}) {
  return showAdaptiveDialog(
    context: context,
    builder:
        (context) => AlertDialog.adaptive(
          title: Text(title),
          content: error == null ? null : Text(error),
          actions: [
            PlatformDialogAction(
              onPressed: Navigator.of(context).pop,
              child: Text('OK'),
            ),
          ],
        ),
  );
}

Future<void> showAccountDeletionDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return PlatformAlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
          'Tapping yes will take you to our support site where you can submit a ticket to delete your account. This process could take up to 30 days.',
        ),
        actions: [
          PlatformDialogAction(
            child: Text('Yes', style: TextStyle(color: Colors.blueAccent)),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => const WebView(
                        url: 'https://docs.viam.com/',
                        title: 'Account Support',
                      ),
                ),
              );
            },
          ),
          PlatformDialogAction(
            child: Text('No', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class AppInfo {
  static String _version = '';

  /// Setup the app info, this is called in the main.dart file, provides the app version for display in the app
  static Future<void> setupInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
  }

  static String get version => _version;
}

// this function is used to make a dummy network call to trigger the iOS local network permission dialog
// and to detect if the user has disabled it, prompting them to go to settings and enable it.
// we have to make the dummy call this way because iOS doesn't offer an API to check the permission,
// or to trigger the prompt manually.
void localNetworkEnabledTest(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOSLocalNetworkPrompt =
      prefs.getBool(Store.hasSeenOSLocalNetworkPromptKey) ?? false;
  if (!hasSeenOSLocalNetworkPrompt) {
    await prefs.setBool(Store.hasSeenOSLocalNetworkPromptKey, true);
  }

  // Android implicitly enables this permission because it is defined in our AndroidManifest, this only needs to be done for iOS.
  if (!Platform.isIOS) return;

  // wait a little before showing the dialog, otherwise it pops up instantly
  await Future.delayed(Duration(seconds: 1));

  try {
    final deviceIp = await NetworkInfo().getWifiIP();
    await Socket.connect(deviceIp, 80, timeout: Duration(milliseconds: 100));
  } on SocketException catch (e) {
    print(e.osError!.errorCode);

    // this errorCode means the Local Network setting has been disabled or not accepted.
    // Show a dialog that prompts the user to the settings page for the app to enable it
    // if the errorCode == 61 that means the user has enabled local netowrk permissions.
    if (e.osError!.errorCode == 65) {
      // Do not show the Alert Dialog if the user hasn't seen the OS local network prompt.
      // The native iOS permission dialog will show automatically the first time.
      if (!hasSeenOSLocalNetworkPrompt) return;

      if (context.mounted) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return PlatformAlertDialog(
              actions: [
                PlatformDialogAction(
                  child: Text(
                    'Go to Settings',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
              title: const Text(
                'Viam Sample App needs access to your local network',
              ),
              content: Text(
                'The app will use your network to connect to your boat. Please enable Local Network access in settings',
              ),
            );
          },
        );
      }
    }
  }
}

ColorFilter get logoFilter {
  double value = 1;
  double delta = 0;
  // if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
  //   value = -1;
  //   delta = 255;
  // }
  return ColorFilter.matrix([
    //R  G   B   A  Const
    value, 0, 0, 0, delta, //
    0, value, 0, 0, delta, //
    0, 0, value, 0, delta, //
    0, 0, 0, 1, 0, //
  ]);
}

/// Returns a DateTime object from a string of the format "1582838400000000000"
DateTime lastAccessToDateTime(Object lastAccess) {
  final values = lastAccess.toString().split('\n');
  if (values.length < 2) {
    return DateTime.now();
  }
  int seconds = int.parse(values[0].split(' ')[1]);
  int nanos = int.parse(values[1].split(' ')[1]);

  int milliseconds = seconds * 1000 + (nanos ~/ 1000000);
  return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
}

/// Returns a string of the date in the format of "1yr" or "1mo" or "1d" or "1h" or "1min"
String dateTimeToDate(DateTime dateTime) {
  final Duration difference = DateTime.now().difference(dateTime);

  if (difference.inDays >= 365) {
    return 'over 1yr';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 28).round()}mo';
  } else if (difference.inHours >= 24) {
    return '${difference.inDays}d';
  } else if (difference.inMinutes >= 60) {
    return '${difference.inHours % 24}h';
  } else if (difference.inMinutes % 60 == 0) {
    return 'moments';
  } else {
    return '${difference.inMinutes % 60}min';
  }
}

/// Returns a string of the time in the format of "12:00 am" or "12:00 pm"
String dateTimeToTime(DateTime dateTime) {
  final hour = dateTime.toLocal().hour;
  final minute = dateTime.toLocal().minute.toString().padLeft(2, '0');

  if (hour == 0) {
    return '12:$minute am';
  } else if (hour == 12) {
    return '12:$minute pm';
  } else if (hour > 12) {
    return '${hour - 12}:$minute pm';
  } else {
    return '$hour:$minute am';
  }
}
