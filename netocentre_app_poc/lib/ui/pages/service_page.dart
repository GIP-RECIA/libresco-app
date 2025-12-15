import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/ui/components/app_container.dart';
import 'package:netocentre_app_poc/ui/components/service_web_view.dart';
import 'package:netocentre_app_poc/utils/custom_cookies_manager.dart';

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
  late CookieManager manager;
  late String uri;

  late InAppWebViewController webViewController;
  PullToRefreshController? pullToRefreshController;
  double progress = 0;

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
                webViewController.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController.loadUrl(
                  urlRequest: URLRequest(
                    url: await webViewController.getUrl(),
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
    log.finer('define url from uri \'${widget.uri}\' : $uri');
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
          ServiceWebView(
            uri: uri,
            pullToRefreshController: pullToRefreshController,
            onProgress: (value) {
              setState(() {
                progress = value;
              });
            },
          ),
        ],
      ),
      bottomNavigation: false,
    );
  }
}
