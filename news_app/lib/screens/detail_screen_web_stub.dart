// Stub for web platform where WebView is not supported
import 'package:flutter/material.dart';

class WebViewControllerWrapper {
  void init({required VoidCallback onPageFinished}) {
    // No-op on web
  }

  void loadUrl(String url) {
    // No-op on web
  }

  Widget buildWidget() {
    return const SizedBox.shrink();
  }
}
