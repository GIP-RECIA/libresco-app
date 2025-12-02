import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';

import '../pages/homePage.dart';
import '../pages/loadingPage.dart';
import '../singletons/appConfig.dart';
import '../singletons/tokenManager.dart';

class AuthenticationInAppBrowser extends InAppBrowser {

  final log = Logger('AuthenticationInAppBrowser');
  BuildContext context;
  CookieManager cookieManager = CookieManager.instance();
  AuthenticationInAppBrowser(this.context);

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
      if(url.toString().contains("${AppConfig().serviceURL}?ticket=")){
        // Get TGT cookie
        log.finest("Looking for TGC cookie");
        List<Cookie> cookies = await cookieManager.getCookies(url: WebUri("https://${AppConfig().casBaseURL}/cas/"));
        for(var current in cookies) {
          log.finest("Checking cookie $current.name");
          if(current.name == "TGC"){
            log.fine("TGC Cookie found with value : $current");
            TokenManager().setTGT(current.value, flush: true);
          }
        }
        // If we have found a TGT, then we can navigate to home page
        if(TokenManager().TGT != ""){
          log.fine("$url was intercepted to get the TGT. Closing browser...");
          close(); // close the navigator
          navigateToHomePage();
        }
        // If no TGT is found, it means there is certainly a problem with the cookies
        else {
          log.warning("TGC cookie wasn't found. There may be a problem with cookies");
          close();
          if(context.mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Erreur lors de l'authentification : essayez de mettre à jour votre navigateur dans sa dernière version."),
                duration: Duration(seconds: 10),
              ),
            );
          }
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