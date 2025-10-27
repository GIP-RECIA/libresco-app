
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netocentre_app_poc/singletons/appConfig.dart';

import '../utils/AuthenticationInAppBrowser.dart';

class UnconnectedHomePage extends StatefulWidget {
  const UnconnectedHomePage({super.key});

  @override
  State<UnconnectedHomePage> createState() => UnconnectedHomePageState();
}

class UnconnectedHomePageState extends State<UnconnectedHomePage> {

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
    return Scaffold(
      body: SingleChildScrollView(
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
                    key: const Key("loginButton"),
                    onPressed: () {
                      browser.openUrlRequest(
                          urlRequest: URLRequest(url: WebUri("https://${AppConfig().casBaseURL}/cas/login?service=${AppConfig().serviceURL}")),
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