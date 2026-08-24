// Copyright (C) 2023 GIP-RECIA, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/session.dart';

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
      url: WebUri('${Account().getBaseUrl()}/'),
      name: AppConfig().portalCookieName,
      value: Session().PortalSessionCookie,
      isHttpOnly: true,
      isSecure: true,
      sameSite: HTTPCookieSameSitePolicy.NONE,
      domain: Account().domain,
      path: '/',
    );
    if (Session().IDPortalCookie != "") {
      manager.setCookie(
        url: WebUri('${Account().getBaseUrl()}/'),
        name: AppConfig().portalIDCookieName,
        value: Session().IDPortalCookie,
        isHttpOnly: true,
        isSecure: true,
        sameSite: HTTPCookieSameSitePolicy.NONE,
        domain: Account().domain,
        path: '/',
      );
    }
  }
}
