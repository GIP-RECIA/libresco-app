import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/pages/components/app_container.dart';
import 'package:netocentre_app_poc/singletons/app_config.dart';
import 'package:netocentre_app_poc/singletons/session.dart';
import 'package:netocentre_app_poc/singletons/user_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final log = Logger('_HomePage');

  @override
  void initState() {
    super.initState();
    defineUPortalCookies();
  }

  void defineUPortalCookies() {
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

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: InAppWebView(
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
      ),
    );
  }
}
