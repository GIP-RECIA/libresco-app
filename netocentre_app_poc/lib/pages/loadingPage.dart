import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netocentre_app_poc/pages/unconnectedHomePage.dart';
import '../services/loginService.dart';
import '../services/portalService.dart';
import '../singletons/tokenManager.dart';

class LoadingPageUtils {

  BuildContext context;
  Widget callbackWidget;

  LoadingPageUtils(this.context, this.callbackWidget);

  Future<void> loadDataFromAPI() async {

    // Try to login to portal once : if we get a user we're connected
    if(!await PortalService().hasPortalSession()){
      // If we get a guest user, try again (if the CAS session is still valid)
      print("PORTAL SESSION IS INVALID");
      await LoginService().unstackedUPortalLogin();
      if(!await PortalService().hasPortalSession()){
        // If we get a guest user again, that means CAS session is not valid, and we need to redo the login phase
        print("CAS SESSION IS INVALID");
        TokenManager().reset(flush: true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UnconnectedHomePage()),
          );
        });
        return;
      } else {
        print("RESTORED PORTAL SESSION BY CREATING A NEW ONE");
      }
    } else {
      print("PORTAL SESSION IS VALID");
    }

    // Once we are sure to be connected, we can request the infos from the portal APIs
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