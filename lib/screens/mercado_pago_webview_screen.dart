import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';

class MercadoPagoWebviewScreen extends StatefulWidget {
  final String initPointUrl;

  const MercadoPagoWebviewScreen({
    super.key,
    required this.initPointUrl,
  });

  @override
  State<MercadoPagoWebviewScreen> createState() => _MercadoPagoWebviewScreenState();
}

class _MercadoPagoWebviewScreenState extends State<MercadoPagoWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if the URL is one of our redirect URLs
            if (request.url.contains('tortasyani.com/success')) {
              Navigator.pop(context, true); // Payment successful
              return NavigationDecision.prevent;
            } else if (request.url.contains('tortasyani.com/failure') || 
                       request.url.contains('tortasyani.com/pending')) {
              Navigator.pop(context, false); // Payment failed or pending
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initPointUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Completar Pago', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFF07070)),
            ),
        ],
      ),
    );
  }
}
