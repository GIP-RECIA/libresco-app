import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/pages/components/app_container.dart';
import 'package:netocentre_app_poc/utils/custom_cookies_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceWebview extends StatefulWidget {
  final String uri;
  final String text;
  final String fname;
  final bool inPortal;

  const ServiceWebview({
    super.key,
    required this.uri,
    required this.text,
    required this.fname,
    required this.inPortal,
  });

  @override
  State<ServiceWebview> createState() => _ServiceWebview();
}

class _ServiceWebview extends State<ServiceWebview> {
  final log = Logger('_ServiceWebview');
  final GlobalKey webViewKey = GlobalKey();
  late CookieManager manager;
  late String uri;

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    userAgent: AppConfig().userAgent,
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
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
            initialSettings: settings,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) async {
              webViewController = controller;
            },
            onLoadStart: (controller, url) async {
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url!;

              if (![
                'http',
                'https',
                'file',
                'chrome',
                'data',
                'javascript',
                'about'
              ].contains(uri.scheme)) {
                if (await canLaunchUrl(uri)) {
                  // Launch the App
                  await launchUrl(
                    uri,
                  );
                  // and cancel the request
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(
                source:
                    'document.querySelectorAll(\'r-header, r-footer, extended-uportal-header, extended-uportal-footer\').forEach(node => node.remove());',
              );
              pullToRefreshController?.endRefreshing();
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
            },
            onReceivedError: (controller, request, error) {
              pullToRefreshController?.endRefreshing();
            },
            onProgressChanged: (controller, progress) async {
              if (progress == 100) {
                pullToRefreshController?.endRefreshing();
              }
              setState(() {
                this.progress = progress / 100;
                urlController.text = url;
              });
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) {
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              if (kDebugMode) {
                log.finer(
                  'Console message ${consoleMessage.toString()}',
                );
              }
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
          ),
        ],
      ),
      bottomNavigation: false,
    );
  }
}
