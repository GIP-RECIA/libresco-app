import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/pages/unconnectedHomePage.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/services/portalService.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

class LoadingPageUtils {
  final log = Logger('LoadingPageUtils');

  BuildContext context;
  Widget callbackWidget;

  LoadingPageUtils(this.context, this.callbackWidget);

  Future<void> loadDataFromAPI() async {
    log.info("Loading data from portal API...");
    // Try to login to portal once : if we get a user we're connected
    if (!await LoginService.instance.hasPortalSession()) {
      // If we get a guest user, try again (if the CAS session is still valid)
      log.info("Portal session is invalid");
      await LoginService.instance.unstackedUPortalLogin();
      if (!await LoginService.instance.hasPortalSession()) {
        // If we get a guest user again, that means CAS session is not valid, and we need to redo the login phase
        log.info("CAS session is invalid");
        TokenManager().reset(flush: true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const UnconnectedHomePage()),
          );
        });
        return;
      } else {
        log.info("Restored portal session by creating a new one");
      }
    } else {
      log.info("Portal session is valid");
    }

    // Once we are sure to be connected, we can request the infos from the portal APIs
    await PortalService.instance.loadUserInfo();
    await PortalService.instance.getAllPortlets();
    log.info("Data was loaded successfully, now exiting loading page...");
    navigatorPush();
  }

  void navigatorPush() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => callbackWidget));
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
