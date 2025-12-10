import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/singletons/app_config.dart';
import 'package:netocentre_app_poc/singletons/session.dart';
import 'package:url_launcher/url_launcher.dart';

class UPortalServiceWebview extends StatefulWidget {
  final String uri;
  final String text;

  const UPortalServiceWebview({
    super.key,
    required this.uri,
    required this.text,
  });

  @override
  State<UPortalServiceWebview> createState() => _UPortalServiceWebview();
}

class _UPortalServiceWebview extends State<UPortalServiceWebview> {
  final log = Logger('_UPortalServiceWebview');
  final GlobalKey webViewKey = GlobalKey();
  late CookieManager manager;

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

    manager = CookieManager.instance();
    manager.removeSessionCookies();

    manager.setCookie(
      url: WebUri('${AppConfig().uPortalBaseURL}/'),
      name: AppConfig().portalCookieName,
      value: Session().PortalSessionCookie,
      isHttpOnly: true,
      isSecure: true,
      sameSite: HTTPCookieSameSitePolicy.NONE,
      domain: AppConfig().uPortalHost,
      path: '/',
    );

    manager.setCookie(
      url: WebUri('${AppConfig().uPortalBaseURL}/'),
      name: AppConfig().portalIDCookieName,
      value: Session().IDPortalCookie,
      isHttpOnly: true,
      isSecure: true,
      sameSite: HTTPCookieSameSitePolicy.NONE,
      domain: AppConfig().uPortalHost,
      path: '/',
    );

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

  @override
  Widget build(BuildContext context) {
    log.finer('on init ${widget.uri} : ${Session().PortalSessionCookie}');
    log.finer('on init ${widget.uri} : ${AppConfig().uPortalBaseURL}/');
    log.finer(
      'on init ${widget.uri} : ${AppConfig().uPortalBaseURL}/portail/p/${widget.uri}',
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                      url: WebUri(
                        '${AppConfig().uPortalBaseURL}/portail/p/${widget.uri}',
                      ),
                    ),
                    initialSettings: settings,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) async {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
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
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
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
                            'Console message ${consoleMessage.toString()}');
                      }
                    },
                    onReceivedServerTrustAuthRequest:
                        (controller, challenge) async {
                      return ServerTrustAuthResponse(
                        action: ServerTrustAuthResponseAction.PROCEED,
                      );
                    },
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  key: const Key('backFromWebviewButton'),
                  child: Text('Quitter ${widget.text}'),
                  onPressed: () {
                    manager.removeSessionCookies();
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.refresh),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
