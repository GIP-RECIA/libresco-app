import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:netocentre_app_poc/singletons/app_config.dart';
import 'package:netocentre_app_poc/singletons/session.dart';

class CustomCookiesManager {
  static void defineCASCookies(CookieManager manager) {
    manager.setCookie(
      url: WebUri('${AppConfig().casBaseURL}/cas'),
      name: AppConfig().casCookieName,
      value: Session().CASSessionCookie,
      isHttpOnly: true,
      isSecure: true,
      sameSite: HTTPCookieSameSitePolicy.NONE,
      domain: AppConfig().casHost,
      path: '/cas',
    );
  }

  static void defineUPortalCookies(CookieManager manager) {
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
    if (Session().IDPortalCookie != "") {
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
}
