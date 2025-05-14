import 'dart:io'; // This detects whe platform
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewApp extends StatefulWidget {
  final String url;

  const WebViewApp({super.key, required this.url});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // This logs all URLs the WebView is trying to load
            debugPrint('Attempting to navigate to: ${request.url}');

            // Block or allow navigation here
            if (request.url.startsWith('https')) {
              return NavigationDecision.navigate;
            } else {
              /* This is blocking the redirects to http://google.com that come from fallback of 
              The Trevor Project's third-party scripts, embedded forms, trackers, etc. when they don't load */
              return NavigationDecision.prevent;
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Platform.isIOS // Only show a leave-webview bar if on iOS
        ? AppBar(
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop(); // Exit web view controller
              },
            ),
            title: Text('WebView'),
          )
        : null,
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}