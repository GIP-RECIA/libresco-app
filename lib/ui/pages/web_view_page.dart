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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:libresco/ui/components/app_container.dart';
import 'package:libresco/ui/components/web_view.dart';
import 'package:libresco/utils/custom_cookies_manager.dart';
import 'package:logging/logging.dart';

class WebViewPage extends StatefulWidget {
  final String appBarTitle;
  final String uri;

  const WebViewPage({
    super.key,
    required this.appBarTitle,
    required this.uri,
  });

  @override
  State<WebViewPage> createState() => _WebViewPage();
}

class _WebViewPage extends State<WebViewPage> {
  final log = Logger('_WebViewPage');
  late CookieManager manager;

  late InAppWebViewController webViewController;
  PullToRefreshController? pullToRefreshController;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _initCookies();
    _definePullToRefreshController();
  }

  void _initCookies() {
    manager = CookieManager.instance();
    manager.deleteAllCookies();
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

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      appBarClose: true,
      onClose: () {
        manager.deleteAllCookies();
        Navigator.pop(context);
      },
      appBarTitle: widget.appBarTitle,
      body: Stack(
        children: [
          if (progress < 1.0) LinearProgressIndicator(value: progress),
          WebView(
            uri: widget.uri,
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
