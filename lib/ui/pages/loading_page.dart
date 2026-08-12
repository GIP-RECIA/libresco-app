import 'dart:io';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:libresco/utils/sanitizer.dart';
import 'package:logging/logging.dart';
import 'package:libresco/objects/enums/user_info_loading_state.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/session.dart';
import 'package:libresco/objects/singletons/user_info.dart';
import 'package:libresco/repositories/session_repository.dart';
import 'package:libresco/services/dnma_service.dart';
import 'package:libresco/services/login_service.dart';
import 'package:libresco/services/portal_service.dart';
import 'package:libresco/ui/pages/unconnected_home_page.dart';

import '../../objects/singletons/account.dart';
import 'home_page.dart';

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

  Future<String> obtainServiceTicket() async{
    log.fine('Obtaining service ticket from CAS');
    final client = HttpClient();
    client.userAgent = AppConfig().userAgent;
    var uri = Uri.https(
      AppConfig().casHost,
      '/cas/login',
      {"service": AppConfig().serviceURL},
    );
    var request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.add(
      'Cookie',
      '${AppConfig().casCookieName}=${Session().CASSessionCookie}',
    );
    log.finest('Making this request to CAS server : ${request.uri.toString()}');
    log.finest('Request headers are : ${sanitizeHeaders(request.headers, visibleCharacters: 3)}');
    var response = await request.close();
    log.finest('Response status code from cas server : ${response.statusCode}');
    log.finest('Response headers: ${sanitizeHeaders(response.headers, visibleCharacters: 3)}');
    String st = response.headers.value("location")!.split("ticket=").last;
    log.finer('Service ticket extracted from headers is : ${sanitize(st, visibleCharacters: 3)}');
    return st;
  }

  Future<void> sendTokenToServer(String token) async {
    String serviceTicket = await obtainServiceTicket();
    final String url = AppConfig().notificationServerUrl;
    final String uid = UserInfo().uid;
    log.info("Sending FCM Token ${sanitize(token, visibleCharacters: 3)} to $url for ${sanitize(uid, visibleCharacters: 3)}");
    await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "ticket": serviceTicket,
        "token": token,
      }),
    );
  }

  Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    String? token = await messaging.getToken();
    if (token != null) {
      await sendTokenToServer(token);
    }
    // Send new token if it changes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      sendTokenToServer(newToken);
    });
  }

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
    UserInfoLoadingState loadingState = await PortalService.instance.loadUserInfo();
    if (loadingState == UserInfoLoadingState.success) {
      log.info('Data was loaded successfully, now exiting loading page...');
      final String uid = UserInfo().uid;
      final bool exists = await SessionRepository.instance.doesAccountAlreadyExists(uid);
      if (exists) {
        log.warning(
          "An account with uid ${sanitize(uid, visibleCharacters: 3)} already exists ! Cleaning the initial account...",
        );
        await SessionRepository.instance.deleteExistingProfile(
          uid,
          Account().id!,
        );
      }
      await DnmaService.instance.mark(AppConfig().dnmaDimension, "Portail", "https://${Account().domain}/portail/f/accueil/normal/render.uP");
      // Once we are logged in we send our token to the notification server
      initFCM();
      navigatorPush();
    } else if(loadingState == UserInfoLoadingState.refresh){
      // We need to wait a little bit to make sur partial logout is finished
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoadingPage(callbackWidget: HomePage()),
          ),
        );
      });
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
