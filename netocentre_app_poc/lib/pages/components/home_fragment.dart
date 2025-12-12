import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/user_info.dart';
import 'package:netocentre_app_poc/utils/custom_cookies_manager.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({
    super.key,
  });

  @override
  State<HomeFragment> createState() => _HomeFragment();
}

class _HomeFragment extends State<HomeFragment> {
  final log = Logger('_HomeFragment');

  @override
  void initState() {
    super.initState();
    _initCookies();
  }

  void _initCookies() {
    CookieManager manager = CookieManager.instance();
    manager.removeSessionCookies();
    CustomCookiesManager.defineUPortalCookies(manager);
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(
          '${AppConfig().staticsBaseURL}/logged.html',
        ),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        userAgent: AppConfig().userAgent,
        supportZoom: false,
        cacheEnabled: AppConfig().cache,
      ),
      onLoadStop: (controller, url) async {
        await controller.evaluateJavascript(
          source:
              'document.getElementById(\'displayname\').innerText = \'${UserInfo().name}\';',
        );
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url;
        if (uri != null && navigationAction.isForMainFrame) {
          // Open web view in new activity
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}
