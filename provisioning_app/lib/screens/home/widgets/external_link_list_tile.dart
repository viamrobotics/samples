import 'package:flutter/material.dart';

import '../../webview.dart';

class ExternalLinkListTile extends StatelessWidget {
  final String title;
  final Icon leadingIcon;
  final String url;

  const ExternalLinkListTile({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: leadingIcon,
      trailing: Icon(Icons.open_in_new),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WebView(url: url, title: title),
          ),
        );
      },
    );
  }
}
