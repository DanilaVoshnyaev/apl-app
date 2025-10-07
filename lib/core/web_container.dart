import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import '../features/header.dart';

class WebContainer extends StatefulWidget {
  final String url;
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
  InAppWebViewController? webController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final langId = appState.langId;

    final uri = Uri.parse(widget.url).replace(
      queryParameters: {
        ...Uri.parse(widget.url).queryParameters,
        'SET_LANG_ID': langId.toString(),
        'no_header': '1'
      },
    );

    return Scaffold(
      appBar: CustomHeader(),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(uri.toString())),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              useHybridComposition: false,
            ),
            onWebViewCreated: (controller) => webController = controller,
            onProgressChanged: (controller, progressValue) {
              setState(() => progress = progressValue / 100);
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
          ),
          if (progress < 1.0) LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }
}
