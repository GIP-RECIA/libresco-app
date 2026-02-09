import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/objects/singletons/user_info.dart';
import 'package:netocentre_app_poc/repositories/session_repository.dart';
import 'package:netocentre_app_poc/services/login_service.dart';
import 'package:netocentre_app_poc/services/portal_service.dart';
import 'package:netocentre_app_poc/ui/pages/unconnected_home_page.dart';

import '../../objects/singletons/account.dart';

class LoadingPage extends StatefulWidget {
  final Widget callbackWidget;

  const LoadingPage({
    required this.callbackWidget,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _LoadingPage();
}

class _LoadingPage extends State<LoadingPage> {
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
            const SizedBox(height: 30),
            Text(
              'Récupération des données en cours.\nVeuillez Patienter.',
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

class LoadingPageUtils {
  final log = Logger('LoadingPageUtils');

  BuildContext context;
  Widget callbackWidget;

  LoadingPageUtils(
    this.context,
    this.callbackWidget,
  );

  Future<void> loadDataFromAPI() async {
    log.info('Loading data from portal API...');
    // Try to login to portal once : if we get a user we're connected
    if (!await LoginService.instance.hasPortalSession()) {
      // If we get a guest user, try again (if the CAS session is still valid)
      log.info('Portal session is invalid');
      await LoginService.instance.unstackedUPortalLogin();
      if (!await LoginService.instance.hasPortalSession()) {
        // If we get a guest user again, that means CAS session is not valid,
        // and we need to redo the login phase
        log.info('CAS session is invalid');
        Session().clear(persist: true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const UnconnectedHomePage(),
            ),
          );
        });
        return;
      } else {
        log.info('Restored portal session by creating a new one');
      }
    } else {
      log.info('Portal session is valid');
    }

    // Once we are sure to be connected, we can request the infos from the
    // portal APIs
    if (await PortalService.instance.loadUserInfo()) {
      log.info('Data was loaded successfully, now exiting loading page...');
      final String uid = UserInfo().uid;
      final bool exists =
          await SessionRepository.instance.doesAccountAlreadyExists(uid);
      if (exists) {
        log.warning(
          "An account with uid $uid already exists ! Cleaning the initial account...",
        );
        await SessionRepository.instance.deleteExistingProfile(
          uid,
          Account().id!,
        );
      }
      navigatorPush();
    } else {
      log.shout('Error during loading');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const UnconnectedHomePage(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue lors de la récupération des données du compte.'
            '\n Veuillez réessayer ultérieurement.',
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }
  }

  void navigatorPush() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => callbackWidget),
    );
  }
}
