import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  static final String routeName = '/privacy';
  final String title;
  final String url;
  const WebViewPage({Key? key, required this.title, required this.url}) : super(key: key);

  @override
  State<WebViewPage> createState() => _NewPageState();
}

class _NewPageState extends State<WebViewPage> {
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      // ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(const Color(0x00000000))
      // ..setNavigationDelegate(
      //   NavigationDelegate(
      //     onProgress: (int progress) {
      //       // Update loading bar.
      //     },
      //     onPageStarted: (String url) {},
      //     onPageFinished: (String url) {},
      //     onWebResourceError: (WebResourceError error) {},
      //   ),
      // )
      ..loadRequest(Uri.parse(widget.url));
  }

  late WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.title),
        ),
        body: WebViewWidget(
          controller: controller,
        ));
  }
}
