import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/ui/components/app_container.dart';
import 'package:netocentre_app_poc/utils/custom_cookies_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicePage extends StatefulWidget {
  final String uri;
  final String text;
  final String fname;
  final bool inPortal;

  const ServicePage({
    super.key,
    required this.uri,
    required this.text,
    required this.fname,
    required this.inPortal,
  });

  @override
  State<ServicePage> createState() => _ServicePage();
}

class _ServicePage extends State<ServicePage> {
  final log = Logger('_ServicePage');
  final GlobalKey webViewKey = GlobalKey();
  late CookieManager manager;
  late String uri;

  InAppWebViewController? webViewController;
  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    userAgent: AppConfig().userAgent,
    supportZoom: false,
    cacheEnabled: AppConfig().cache,
  );

  PullToRefreshController? pullToRefreshController;
  String url = '';
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCookies();
    _definePullToRefreshController();
    _defineUri();
  }

  void _initCookies() {
    manager = CookieManager.instance();
    manager.removeSessionCookies();
    CustomCookiesManager.defineCASCookies(manager);
    CustomCookiesManager.defineUPortalCookies(manager);
  }

  void _definePullToRefreshController() {
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: await webViewController?.getUrl(),
                  ),
                );
              }
            },
          );
  }

  void _defineUri() {
    uri = '${AppConfig().uPortalBaseURL}/portail/p/${widget.uri}';
    if (!widget.inPortal) {
      uri = '${AppConfig().uPortalBaseURL}'
          '/portail/api/ExternalURLStats'
          '?fname=${widget.fname}'
          '&service=${widget.uri}';
    }

    log.finer(
      'on init ${widget.uri} : $uri | PortalSessionCookie : ${Session().PortalSessionCookie}',
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
  }

  void _onLoadStart(InAppWebViewController controller, WebUri? url) {
    _updateUrl(url);
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? url) async {
    await controller.evaluateJavascript(
      source: 'document.querySelectorAll(\''
          'r-header, '
          'r-footer, '
          'extended-uportal-header, '
          'extended-uportal-footer'
          '\').forEach(node => node.remove());',
    );
    pullToRefreshController?.endRefreshing();
    _updateUrl(url);
  }

  void _onProgressChanged(InAppWebViewController controller, int progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    setState(() {
      this.progress = progress / 100;
    });
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

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    var uri = navigationAction.request.url!;

    if (!['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about']
        .contains(uri.scheme)) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return NavigationActionPolicy.CANCEL;
      }
    }
    return NavigationActionPolicy.ALLOW;
  }

  void _onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    pullToRefreshController?.endRefreshing();
  }

  void _onUpdateVisitedHistory(
    InAppWebViewController controller,
    WebUri? url,
    bool? androidIsReload,
  ) {
    _updateUrl(url);
  }

  void _onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage consoleMessage,
  ) {
    if (kDebugMode) {
      log.finer('Console message ${consoleMessage.toString()}');
    }
  }

  Future<ServerTrustAuthResponse> _onReceivedServerTrustAuthRequest(
    InAppWebViewController controller,
    URLAuthenticationChallenge challenge,
  ) async {
    return ServerTrustAuthResponse(
      action: ServerTrustAuthResponseAction.PROCEED,
    );
  }

  void _updateUrl(WebUri? url) {
    setState(() {
      this.url = url.toString();
      urlController.text = this.url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      appBarBack: true,
      onBack: () {
        manager.removeSessionCookies();
        Navigator.pop(context);
      },
      appBarTitle: widget.text,
      body: Stack(
        children: [
          if (progress < 1.0) LinearProgressIndicator(value: progress),
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(uri)),
            initialSettings: _webViewSettings,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: _onWebViewCreated,
            onLoadStart: _onLoadStart,
            onLoadStop: _onLoadStop,
            onProgressChanged: _onProgressChanged,
            onPermissionRequest: _onPermissionRequest,
            shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
            onReceivedError: _onReceivedError,
            onUpdateVisitedHistory: _onUpdateVisitedHistory,
            onConsoleMessage: _onConsoleMessage,
            onReceivedServerTrustAuthRequest: _onReceivedServerTrustAuthRequest,
          ),
        ],
      ),
      bottomNavigation: false,
    );
  }
}
