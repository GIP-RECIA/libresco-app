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
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/utils/web_view_utils.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class WebView extends StatefulWidget {
  final String uri;
  final PullToRefreshController? pullToRefreshController;
  final ValueChanged<double>? onProgress;

  const WebView({
    super.key,
    required this.uri,
    required this.pullToRefreshController,
    this.onProgress,
  });

  @override
  State<WebView> createState() => _WebView();
}

class _WebView extends State<WebView> {
  final log = Logger('_WebView');
  InAppWebViewController? controller;

  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    userAgent: AppConfig().userAgent,
    supportZoom: false,
    cacheEnabled: AppConfig().cache,
  );

  Future<void> _onLoadStop(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    await controller.evaluateJavascript(
      source: 'document.querySelectorAll(\''
          'r-header, '
          'r-footer, '
          'extended-uportal-header, '
          'extended-uportal-footer'
          '\').forEach(node => node.remove());',
    );
    await controller.evaluateJavascript(
      source: 'document.body.setAttribute(\'style\', '
          '\'--recia-header-height: 0px !important;\');',
    );
    await controller.evaluateJavascript(
      source: 'document.querySelector(\'body.portal\')'
          '.setAttribute(\'style\', \'margin-top: 0px !important;\');',
    );

    widget.pullToRefreshController?.endRefreshing();
  }

  void _onProgressChanged(
    InAppWebViewController controller,
    int progress,
  ) {
    widget.onProgress?.call(progress / 100);
    if (progress == 100) {
      widget.pullToRefreshController?.endRefreshing();
    }
  }

  Future<NavigationActionPolicy> _overrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final uri = action.request.url;

    if (uri == null || !action.isForMainFrame) {
      return NavigationActionPolicy.ALLOW;
    }

    if (WebViewUtils.isInsideNavigation(uri.host)) {
      return NavigationActionPolicy.ALLOW;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    }

    return NavigationActionPolicy.CANCEL;
  }

  Future<PermissionResponse> _onPermissionRequest(
    InAppWebViewController controller,
    PermissionRequest request,
  ) async {
    return PermissionResponse(
      resources: request.resources,
      action: PermissionResponseAction.GRANT,
    );
  }

  void _onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage message,
  ) {
    if (kDebugMode) {
      log.finer(
        '[Console][${message.messageLevel.toString()}] ${message.message}',
      );
    }
  }

  void _onError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    widget.pullToRefreshController?.endRefreshing();
  }

  Future<void> _onDownloadStartRequest(
    InAppWebViewController controller,
    DownloadStartRequest request,
  ) async {
    log.fine('Download ${request.url}');
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.uri)),
      initialSettings: _webViewSettings,
      pullToRefreshController: widget.pullToRefreshController,
      onWebViewCreated: (controller) => this.controller = controller,
      onLoadStop: _onLoadStop,
      onProgressChanged: _onProgressChanged,
      shouldOverrideUrlLoading: _overrideUrlLoading,
      onPermissionRequest: _onPermissionRequest,
      onConsoleMessage: _onConsoleMessage,
      onReceivedError: _onError,
      onDownloadStartRequest: _onDownloadStartRequest,
    );
  }
}
