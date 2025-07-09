  // import 'dart:io';
  // import 'package:flutter/material.dart';
  // import 'package:webview_flutter/webview_flutter.dart';
  // import 'package:webview_flutter_android/webview_flutter_android.dart'; // ✅ Required for SurfaceAndroidWebView
  //
  // class WebViewPage extends StatefulWidget {
  //   final String url;
  //   const WebViewPage({super.key, required this.url});
  //
  //   @override
  //   State<WebViewPage> createState() => _WebViewPageState();
  // }
  //
  // class _WebViewPageState extends State<WebViewPage> {
  //   late final WebViewController _controller;
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //
  //     // ✅ Only set for Android to enable hybrid composition
  //     if (Platform.isAndroid) {
  //       WebViewPlatform.instance = SurfaceAndroidWebView();
  //     }
  //
  //     _controller = WebViewController()
  //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //       ..setNavigationDelegate(
  //         NavigationDelegate(
  //           onPageStarted: (url) => debugPrint('Loading: $url'),
  //           onPageFinished: (url) => debugPrint('Loaded: $url'),
  //           onWebResourceError: (error) =>
  //               debugPrint('Error loading page: $error'),
  //         ),
  //       )
  //       ..loadRequest(Uri.parse(widget.url));
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(title: const Text("Web View")),
  //       body: WebViewWidget(controller: _controller),
  //     );
  //   }
  // }
