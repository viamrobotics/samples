import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  final String url;
  final String title;
  const WebView({super.key, required this.url, required this.title});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(widget.url));

    controller.setNavigationDelegate(
      NavigationDelegate(
        onUrlChange: (url) {
          final uri = Uri.parse(url.url!);
          if (!uri.queryParameters.containsKey('hide_nav')) {
            // if the url does not have the hide_nav query parameter, add it
            final newUri = uri.replace(
              queryParameters: {...uri.queryParameters, 'hide_nav': '1'},
            );
            controller.loadRequest(newUri);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;
    double leadingWidth = kToolbarHeight;

    // If the title is empty, we need to show a back button with a text label
    if (widget.title.isEmpty) {
      leadingWidth = 100.0;
      leadingWidget = TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.arrow_back), SizedBox(width: 8), Text('Back')],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: leadingWidget,
        leadingWidth: leadingWidth,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
