import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/singletons/app_config.dart';
import 'package:netocentre_app_poc/singletons/session.dart';
import 'package:netocentre_app_poc/singletons/user_info.dart';

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
    _defineUPortalCookies();
  }

  void _defineUPortalCookies() {
    CookieManager manager = CookieManager.instance();
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
    if(Session().IDPortalCookie != ""){
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
    }
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
