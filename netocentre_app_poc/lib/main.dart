import 'package:flutter/material.dart';
import 'package:netocentre_app_poc/pages/homePage.dart';
import 'package:netocentre_app_poc/pages/loadingPage.dart';
import 'package:netocentre_app_poc/pages/unconnectedHomePage.dart';
import 'package:netocentre_app_poc/repositories/tokenRepository.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("token manager before loaded : ${TokenManager().toString()}");
  await TokenRepository().getLastValidRefreshToken();
  print("token manager after loaded : ${TokenManager().toString()}");
  bool connected = await LoginService().hasCASSession();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: connected
        ? const LoadingPage(callbackWidget: HomePage())
        : const UnconnectedHomePage(),
  ));
}
