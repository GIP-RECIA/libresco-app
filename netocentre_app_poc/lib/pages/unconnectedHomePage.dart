
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netocentre_app_poc/pages/components/myAppBar.dart';
import 'package:netocentre_app_poc/pages/homePage.dart';
import 'package:netocentre_app_poc/pages/loadingPage.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/singletons/baseUrl.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

import 'components/newsCard.dart';

class UnconnectedHomePage extends StatefulWidget {
  const UnconnectedHomePage({super.key});

  @override
  State<UnconnectedHomePage> createState() => UnconnectedHomePageState();
}

class UnconnectedHomePageState extends State<UnconnectedHomePage> {

  static const String title = 'Une actualité concernant des évènements actuels';
  static const String type = 'Établissement';
  static const String desc = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  late InAppBrowser browser;

  final settings = InAppBrowserClassSettings(
      browserSettings: InAppBrowserSettings(hideUrlBar: false),
      webViewSettings: InAppWebViewSettings(
          javaScriptEnabled: true, isInspectable: kDebugMode, useShouldInterceptRequest: true, userAgent: HttpClient().userAgent!));


  @override
  void initState() {
    super.initState();
    browser = AuthenticationInAppBrowser(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldwithIntegratedSearchBar(
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    "Connectez-vous",
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "à votre environnement numérique de travail (ENT)",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 150,
                child: ElevatedButton(
                    onPressed: () {
                      browser.openUrlRequest(
                          urlRequest: URLRequest(url: WebUri("https://${BaseUrl().casBaseURL}/cas/login?service=${BaseUrl().serviceURL}")),
                          settings: settings);
                    },
                    child: const Text("Se connecter")
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "Actualités",
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const NewsCard(title, type, desc),
              const NewsCard(title, type, desc),
              const NewsCard(title, type, desc),
              const SizedBox(
                height: 30,
              ),
              Text("{inser video debuter sur ent}"),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    "Découvrir l'ENT",
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Text("{inser menu (lorem ipsum) + tuiles}"),
            ]
        ),
      ),
    );
  }
}

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