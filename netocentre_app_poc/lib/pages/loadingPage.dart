import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/portalService.dart';

class LoadingPageUtils {

  BuildContext context;
  Widget callbackWidget;

  LoadingPageUtils(this.context, this.callbackWidget);

  Future<void> loadDataFromAPI() async {

    await PortalService().loadUserInfo();
    await PortalService().getAllPortlets();
    await PortalService().mediacentreFavoritesWorkflow();

    navigatorPush();
  }

  navigatorPush(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => callbackWidget));
  }
}

class LoadingPage extends StatefulWidget {

  final Widget callbackWidget;

  const LoadingPage({required this.callbackWidget, super.key});

  @override
  State<StatefulWidget> createState() => LoadingPageState();

}

class LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
    LoadingPageUtils(context, widget.callbackWidget).loadDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: const LinearProgressIndicator(),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Récupération des données en cours.\nVeuillez Patienter.",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );

  }
}