import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/pages/homePage.dart';
import 'package:netocentre_app_poc/pages/loadingPage.dart';
import 'package:netocentre_app_poc/pages/unconnectedHomePage.dart';
import 'package:netocentre_app_poc/repositories/tokenRepository.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/singletons/appConfig.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

final log = Logger('main');

Future<Widget> buildApp() async {

  log.fine("Starting app...");
  await TokenRepository.instance.getCookiesInDB();
  bool connected = await LoginService.instance.hasCASSession();
  if (!connected) {
    log.fine("User is not connected to CAS : database reset");
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
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.time} ${record.level.name} [${record.loggerName}] - ${record.message}');
  });
  await AppConfig().loadConfig();
  final app = await buildApp();
  runApp(app);
}