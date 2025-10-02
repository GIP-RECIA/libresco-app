import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';

import '../pages/homePage.dart';
import '../pages/loadingPage.dart';
import '../services/loginService.dart';
import '../singletons/baseUrl.dart';
import '../singletons/tokenManager.dart';

class AuthenticationInAppBrowser extends InAppBrowser {

  final log = Logger('AuthenticationInAppBrowser');
  BuildContext context;
  CookieManager cookieManager = CookieManager.instance();
  AuthenticationInAppBrowser(this.context);

  @override
  InAppWebViewController? get webViewController => super.webViewController;

  LoginService loginService = LoginService();

  void navigateToHomePage(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoadingPage(callbackWidget: HomePage())));
  }

  @override
  Future onBrowserCreated() async {
    log.fine("Browser Created!");
  }

  // This method is called when the browser loads a new url (~= new request)
  @override
  Future onLoadStart(url) async {
    // We get the cookies and try to detect if there is the TGT when we see the login answer from CAS
    log.fine("Started $url");
    if(url != null){
      if(url.toString().contains(BaseUrl().serviceURL)){
        // Get TGT cookie
        List<Cookie> cookies = await cookieManager.getCookies(url: WebUri("https://${BaseUrl().casBaseURL}/cas"));
        for(var current in cookies) {
          if(current.name == "TGC"){
            log.fine("TGT Cookie found with value : $current");
            TokenManager().setTGT(current.value, flush: true);
          }
        }
        // If we have found a TGT, then we can navigate to home page
        if(TokenManager().TGT != ""){
          log.fine("$url was intercepted to get the TGT. Closing browser...");
          close(); // close the navigator
          navigateToHomePage();
        }
      }
    }
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    log.fine("Can't load ${request.url}.. Error: ${error.description}");
  }

  @override
  void onExit() {
    log.fine("Browser closed!");
    // remove session cookies to avoid lost cookies
    cookieManager.removeSessionCookies();
  }

}