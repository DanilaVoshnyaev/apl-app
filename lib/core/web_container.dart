import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'app_state.dart';
import 'package:provider/provider.dart';

class WebContainer extends StatefulWidget {
  final String url; // конечная страница после авторизации
  final String title;

  const WebContainer({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebContainer> createState() => _WebContainerState();
}

class _WebContainerState extends State<WebContainer> {
  InAppWebViewController? _controller;
  double _progress = 0;

  String _buildUrlWithAuth(AppState appState) {
    final token = appState.token ?? "";
    final login = (appState.user?['login'] ?? "").toString();
    const devid = "auth_app";

    final uri = Uri.parse(widget.url).replace(queryParameters: {
      "token": token,
      "login_as_partner": login,
      "devid": devid,
      "letmein": 'Ncb4VNysLz',
    });

    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final authorizedUrl = _buildUrlWithAuth(appState);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: false,
              cacheEnabled: false,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              useHybridComposition: true,
            ),
            onWebViewCreated: (controller) async {
              _controller = controller;
              await controller.loadUrl(
                urlRequest: URLRequest(url: WebUri(authorizedUrl)),
              );
            },
            onLoadStop: (controller, url) async {
              setState(() => _progress = 1);
            },
            onProgressChanged: (controller, progress) {
              setState(() => _progress = progress / 100);
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
          ),
          if (_progress < 1) LinearProgressIndicator(value: _progress),
        ],
      ),
    );
  }
}
