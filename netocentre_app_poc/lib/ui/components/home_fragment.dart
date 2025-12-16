import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/user_info.dart';
import 'package:netocentre_app_poc/ui/pages/web_view_page.dart';
import 'package:netocentre_app_poc/utils/custom_cookies_manager.dart';
import 'package:netocentre_app_poc/utils/web_view_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeFragment extends StatefulWidget {
  final InAppWebViewKeepAlive keepAlive;

  const HomeFragment({
    super.key,
    required this.keepAlive,
  });

  @override
  State<HomeFragment> createState() => _HomeFragment();
}

class _HomeFragment extends State<HomeFragment> {
  final log = Logger('_HomeFragment');

  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    userAgent: AppConfig().userAgent,
    supportZoom: false,
    cacheEnabled: AppConfig().cache,
  );

  @override
  void initState() {
    super.initState();
    _initCookies();
  }

  void _initCookies() {
    CookieManager manager = CookieManager.instance();
    manager.removeSessionCookies();
    CustomCookiesManager.defineCASCookies(manager);
    CustomCookiesManager.defineUPortalCookies(manager);
  }

  Future<void> _onLoadStop(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    await controller.evaluateJavascript(
      source: 'document.getElementById(\'displayname\')'
          '.innerText = \'${UserInfo().name}\';',
    );
  }

  Future<NavigationActionPolicy> _overrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final uri = action.request.url;
    if (uri != null) {
      log.fine('==> $uri | ${uri.host}');
    }

    if (uri == null || !action.isForMainFrame) {
      return NavigationActionPolicy.ALLOW;
    }

    if (WebViewUtils.isInsideNavigation(uri.host)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WebViewPage(
            appBarTitle: '',
            uri: uri.toString(),
          ),
        ),
      );
      return NavigationActionPolicy.CANCEL;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    }

    return NavigationActionPolicy.CANCEL;
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      keepAlive: widget.keepAlive,
      initialUrlRequest: URLRequest(
        url: WebUri('${AppConfig().staticsBaseURL}/logged.html'),
      ),
      initialSettings: _webViewSettings,
      onLoadStop: _onLoadStop,
      shouldOverrideUrlLoading: _overrideUrlLoading,
    );
  }
}
