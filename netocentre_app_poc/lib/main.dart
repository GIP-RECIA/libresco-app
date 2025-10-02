import 'package:flutter/material.dart';
import 'package:netocentre_app_poc/pages/homePage.dart';
import 'package:netocentre_app_poc/pages/loadingPage.dart';
import 'package:netocentre_app_poc/pages/unconnectedHomePage.dart';
import 'package:netocentre_app_poc/repositories/tokenRepository.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

Future<Widget> buildApp() async {

  await TokenRepository().getLastValidRefreshToken();
  bool connected = await LoginService().hasCASSession();
  if (!connected) {
    TokenManager().reset(flush: true);
  }

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: connected
        ? const LoadingPage(callbackWidget: HomePage())
        : const UnconnectedHomePage(),
  );
}

Future<void> main({TokenRepository? tokenRepository, TokenManager? tokenManager, LoginService? loginService,}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = await buildApp();
  runApp(app);
}