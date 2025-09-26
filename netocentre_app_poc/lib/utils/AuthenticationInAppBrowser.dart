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

  // This method is called when the browser loads a new url (~= new request)
  @override
  Future onLoadStart(url) async {
    // For every request we get the cookies and try to detect if there is the TGT
    print("Started $url");
    await getMyCookies();
    if(url != null){
      if(url.toString().contains("https://${BaseUrl().casBaseURL}/appMobile")){
        if(TokenManager().TGT != ""){
          print("this request was intercepted $url");
          close(); // close the navigator
          navigateToHomePage();
        }
      }
    }
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    print("Can't load ${request.url}.. Error: ${error.description}");
  }

  @override
  void onExit() {
    print("Browser closed!");
    // remove session cookies to avoid lost cookies
    cookieManager.removeSessionCookies();
  }

  @override
  Future<ServerTrustAuthResponse> onReceivedServerTrustAuthRequest(
      URLAuthenticationChallenge challenge) async {
    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
  }

}