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

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/user_info.dart';
import 'package:libresco/ui/pages/web_view_page.dart';
import 'package:libresco/utils/custom_cookies_manager.dart';
import 'package:libresco/utils/home_model.dart';
import 'package:libresco/utils/web_view_utils.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeFragment extends StatefulWidget {
  final InAppWebViewKeepAlive keepAlive;
  final HomeModel homeModel;

  const HomeFragment({
    super.key,
    required this.keepAlive,
    required this.homeModel,
  });

  @override
  State<HomeFragment> createState() => _HomeFragment();
}

class _HomeFragment extends State<HomeFragment> {
  final log = Logger('_HomeFragment');
  InAppWebViewController? controller;

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
    widget.homeModel.addListener(_onFavoritesUpdated);
  }

  @override
  void dispose() {
    widget.homeModel.removeListener(_onFavoritesUpdated);
    super.dispose();
  }

  void _initCookies() {
    CookieManager manager = CookieManager.instance();
    manager.deleteAllCookies();
    CustomCookiesManager.defineCASCookies(manager);
    CustomCookiesManager.defineUPortalCookies(manager);
  }

  Future<void> _onFavoritesUpdated() async {
    await controller?.evaluateJavascript(
      source: 'document.dispatchEvent(new CustomEvent(\'update-favorites\'));',
    );
  }

  Future<void> _onLoadStop(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    final String displayname = jsonEncode(UserInfo().name);
    await controller.evaluateJavascript(
      source: 'document.getElementById(\'displayname\')'
          '.innerText = $displayname;',
    );
  }

  Future<NavigationActionPolicy> _overrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final uri = action.request.url;
    final navigationType = action.navigationType;

    if (uri == null ||
        !action.isForMainFrame ||
        navigationType == NavigationType.OTHER ||
        navigationType == NavigationType.RELOAD ||
        navigationType == NavigationType.BACK_FORWARD) {
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
        url: WebUri(
          '${Account().getBaseUrl()}${AppConfig().staticsPath}/logged.html',
        ),
      ),
      initialSettings: _webViewSettings,
      onLoadStop: _onLoadStop,
      onWebViewCreated: (controller) => this.controller = controller,
      shouldOverrideUrlLoading: _overrideUrlLoading,
    );
  }
}
