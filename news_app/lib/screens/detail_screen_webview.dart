// WebView wrapper for mobile platforms
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewControllerWrapper {
  late WebViewController _controller;

  void init({required VoidCallback onPageFinished}) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            onPageFinished();
          },
        ),
      );
  }

  void loadUrl(String url) {
    _controller.loadRequest(Uri.parse(url));
  }

  Widget buildWidget() {
    return WebViewWidget(controller: _controller);
  }
}
