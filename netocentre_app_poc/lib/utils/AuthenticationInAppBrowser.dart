import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../pages/homePage.dart';
import '../pages/loadingPage.dart';
import '../services/loginService.dart';
import '../singletons/baseUrl.dart';
import '../singletons/tokenManager.dart';

class AuthenticationInAppBrowser extends InAppBrowser {

  BuildContext context;

  CookieManager cookieManager = CookieManager.instance();

  AuthenticationInAppBrowser(this.context);

  @override
  InAppWebViewController? get webViewController => super.webViewController;

  LoginService loginService = LoginService();

  void navigateToHomePage(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoadingPage(callbackWidget: HomePage())));
  }

  Future<void> getMyCookies() async{
    List<Cookie> cookies = await cookieManager.getCookies(url: WebUri("https://${BaseUrl().casBaseURL}/cas"));
    for(var current in cookies) {
      print("in login webview - from cookie manager : $current");
      if(current.name == "TGC"){
        print("=======================================\n=== $current ===\n=======================================\n");
        TokenManager().setTGT(current.value, flush: true);
        print("TGT WAS SET");
      }
    }
  }

  @override
  Future onBrowserCreated() async {
    print("Browser Created!");
  }


  @override
  Future onLoadStart(url) async { // used to catch CAS "connected page"
    await getMyCookies();
    print("Started $url");
    if(url != null){
      if(url.toString().contains("https://${BaseUrl().casBaseURL}/cas")){
        if(TokenManager().TGT != ""){
          cookieManager.removeSessionCookies(); // remove session cookies to avoid lost cookies
          close(); // close the navigator
          navigateToHomePage();
        }
      }
    }
  }

  @override
  Future onLoadStop(url) async {
    print("Stopped $url");
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    print("Can't load ${request.url}.. Error: ${error.description}");
  }

  @override
  void onProgressChanged(progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("Browser closed!");
  }

  @override
  Future<ServerTrustAuthResponse> onReceivedServerTrustAuthRequest(
      URLAuthenticationChallenge challenge) async {
    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
  }

  @override
  Future<WebResourceResponse?>? shouldInterceptRequest(
      WebResourceRequest request) {
    print("request intercepted : ${request.url.toString()}");
    return null;
  }

  @override
  void onUpdateVisitedHistory(WebUri? url, bool? isReload) {
    if(url != null){
      print("updated history : ${url.toString()}");
    }
  }
}