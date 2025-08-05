import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../consts.dart';
import '../../../utils.dart';

import '../home_view_model.dart';
import 'external_link_list_tile.dart';

class MainMenuDrawer extends StatefulWidget {
  final HomeViewModel _homeViewModel;
  final AuthService _authService;
  const MainMenuDrawer({
    super.key,
    required AuthService authService,
    required HomeViewModel homeViewModel,
  }) : _homeViewModel = homeViewModel,
       _authService = authService;

  @override
  State<MainMenuDrawer> createState() => _MainMenuDrawerState();
}

class _MainMenuDrawerState extends State<MainMenuDrawer> {
  ViamUserProfile? user;
  bool loading = true;
  String? jwt;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    user = await widget._authService.currentUser;
    setState(() {
      loading = false;
    });
    jwt = await widget._authService.accessToken;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, bottom: 10),
                        child: SizedBox(
                          height: 40,
                          // TODO: replace with your logo
                          child: Image.asset('images/logo-black-no-words.png'),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text(user?.name ?? ''),
                    subtitle: Text(user?.email ?? ''),
                  ),

                  ListenableBuilder(
                    listenable: widget._homeViewModel,
                    builder: (context, child) {
                      final selectedOrg = widget._homeViewModel.selectedOrg;

                      if (selectedOrg == null) {
                        return const SizedBox.shrink();
                      }

                      return ListTile(
                        leading: Icon(Icons.settings_outlined),
                        title: Text(selectedOrg.name),
                        onTap: () {
                          widget._homeViewModel.onChangeOrgPressed(context);
                        },
                      );
                    },
                  ),

                  ListTile(
                    title: Text('Log out'),
                    leading: Icon(Icons.logout),
                    onTap: () {
                      showLogoutDialog(
                        context,
                        () => widget._authService.logoutAction(),
                      );
                    },
                  ),
                  Divider(),
                ],
              ),
            ),
            Divider(),
            ExternalLinkListTile(
              title: 'Help & Support',
              leadingIcon: Icon(Icons.help_outline),
              url: Urls.helpAndSupport,
            ),
            ExternalLinkListTile(
              title: 'Privacy Policy',
              leadingIcon: Icon(Icons.privacy_tip_outlined),
              url: Urls.privacyPolicy,
            ),
            ExternalLinkListTile(
              title: 'Terms of Service',
              leadingIcon: Icon(Icons.article_outlined),
              url: Urls.termsOfService,
            ),

            ListTile(
              textColor: Colors.redAccent,
              title: Text('Delete Account'),
              leading: Icon(Icons.person_off_sharp, color: Colors.redAccent),
              trailing: Icon(Icons.open_in_new, color: Colors.redAccent),
              onTap: () {
                showAccountDeletionDialog(context);
              },
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  spacing: 16,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Image.asset('images/powered-by-viam.png'),
                    ),
                    Text('v ${AppInfo.version}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
