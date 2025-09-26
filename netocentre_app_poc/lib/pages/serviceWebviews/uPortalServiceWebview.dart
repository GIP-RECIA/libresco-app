import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:netocentre_app_poc/singletons/baseUrl.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';
import 'package:url_launcher/url_launcher.dart';

class UPortalServiceWebview extends StatefulWidget {
  final String uri;
  final String text;
  const UPortalServiceWebview({super.key, required this.uri, required this.text});

  @override
  State<UPortalServiceWebview> createState() => UPortalServiceWebviewState();
}

class UPortalServiceWebviewState extends State<UPortalServiceWebview> {

  final GlobalKey webViewKey = GlobalKey();

  late CookieManager manager;

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    manager = CookieManager.instance();

    manager.setCookie(
    url: WebUri("https://${BaseUrl().uPortalBaseURL}/"),
    name: "JSESSIONID",
    value: TokenManager().JSESSIONID,
    isHttpOnly: true,
    isSecure: true,
    sameSite: HTTPCookieSameSitePolicy.NONE,
    domain: BaseUrl().uPortalBaseURL,
    path: "/",
    );

    manager.setCookie(
    url: WebUri("https://${BaseUrl().uPortalBaseURL}/"),
    name: "clusterIDPortail",
    value: TokenManager().idPortal,
    isHttpOnly: true,
    isSecure: true,
    sameSite: HTTPCookieSameSitePolicy.NONE,
    domain: BaseUrl().uPortalBaseURL,
    path: "/",
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
              urlRequest:
              URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("on init ${widget.uri} : ${TokenManager().JSESSIONID}");
    print("on init ${widget.uri} : https://${BaseUrl().uPortalBaseURL}/");
    print("on init ${widget.uri} : https://${BaseUrl().uPortalBaseURL}/portail/p/${widget.uri}");
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: WebUri("https://${BaseUrl().uPortalBaseURL}/portail/p/${widget.uri}")),
                      initialSettings: settings,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) async {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                          print(this.url);
                        });
                      },
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;

                        if (![
                          "http",
                          "https",
                          "file",
                          "chrome",
                          "data",
                          "javascript",
                          "about"
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
                          print(consoleMessage);
                        }
                      },
                      onReceivedServerTrustAuthRequest: (controller, challenge) async {
                        print(challenge);
                        return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                      },
                    ),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: Text("Quitter ${widget.text}"),
                    onPressed: () {
                      manager.removeSessionCookies();
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Icon(Icons.refresh),
                    onPressed: () {
                    },
                  ),
                ],
              ),
            ])));
  }
}