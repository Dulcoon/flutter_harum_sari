import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/toast_utils.dart';

class PaymentScreen extends StatelessWidget {
  final String snapToken;

  const PaymentScreen({super.key, required this.snapToken});

  @override
  Widget build(BuildContext context) {
    final url = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
        onWebViewCreated: (controller) {
          // Additional setup if needed
        },
        onLoadStart: (controller, url) {
          // Handle load start
        },
        onLoadStop: (controller, url) async {
          // Handle load stop
        },
        onLoadError: (controller, url, code, message) {
          ToastUtils.showToastMessage(message);
        },
      ),
    );
  }
}
