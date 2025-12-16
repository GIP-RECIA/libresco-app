import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class WebView extends StatefulWidget {
  final String uri;
  final PullToRefreshController? pullToRefreshController;
  final ValueChanged<double>? onProgress;

  const WebView({
    super.key,
    required this.uri,
    required this.pullToRefreshController,
    this.onProgress,
  });

  @override
  State<WebView> createState() => _WebView();
}

class _WebView extends State<WebView> {
  final log = Logger('_WebView');
  InAppWebViewController? controller;

  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    userAgent: AppConfig().userAgent,
    supportZoom: false,
    cacheEnabled: AppConfig().cache,
  );

  Future<void> _onLoadStop(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    await controller.evaluateJavascript(
      source: 'document.querySelectorAll(\''
          'r-header, '
          'r-footer, '
          'extended-uportal-header, '
          'extended-uportal-footer'
          '\').forEach(node => node.remove());',
    );
    widget.pullToRefreshController?.endRefreshing();
  }

  void _onProgressChanged(
    InAppWebViewController controller,
    int progress,
  ) {
    widget.onProgress?.call(progress / 100);
    if (progress == 100) {
      widget.pullToRefreshController?.endRefreshing();
    }
  }

  Future<NavigationActionPolicy> _overrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final uri = action.request.url!;
    if (!['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about']
        .contains(uri.scheme)) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return NavigationActionPolicy.CANCEL;
      }
    }
    return NavigationActionPolicy.ALLOW;
  }

  Future<PermissionResponse> _onPermissionRequest(
    InAppWebViewController controller,
    PermissionRequest request,
  ) async {
    return PermissionResponse(
      resources: request.resources,
      action: PermissionResponseAction.GRANT,
    );
  }

  void _onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage message,
  ) {
    if (kDebugMode) {
      log.finer(
        '[Console][${message.messageLevel.toString()}] ${message.message}',
      );
    }
  }

  Future<ServerTrustAuthResponse> _onServerTrust(
    InAppWebViewController controller,
    URLAuthenticationChallenge challenge,
  ) async {
    return ServerTrustAuthResponse(
      action: ServerTrustAuthResponseAction.PROCEED,
    );
  }

  void _onError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    widget.pullToRefreshController?.endRefreshing();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.uri)),
      initialSettings: _webViewSettings,
      pullToRefreshController: widget.pullToRefreshController,
      onWebViewCreated: (controller) => this.controller = controller,
      onLoadStop: _onLoadStop,
      onProgressChanged: _onProgressChanged,
      shouldOverrideUrlLoading: _overrideUrlLoading,
      onPermissionRequest: _onPermissionRequest,
      onConsoleMessage: _onConsoleMessage,
      onReceivedServerTrustAuthRequest: _onServerTrust,
      onReceivedError: _onError,
    );
  }
}
