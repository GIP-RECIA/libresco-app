import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/account.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/repositories/session_repository.dart';
import 'package:netocentre_app_poc/services/login_service.dart';
import 'package:netocentre_app_poc/ui/pages/home_page.dart';
import 'package:netocentre_app_poc/ui/pages/loading_page.dart';
import 'package:netocentre_app_poc/ui/pages/unconnected_home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

final log = Logger('main');

Future<Widget> buildApp() async {
  log.fine('Starting app...');
  bool connected = false;
  List<Map<String, Object?>> profiles =
      await SessionRepository.instance.getProfilesList();
  if (profiles.length == 1) {
    Account().setId(profiles[0]['id'] as int);
    await SessionRepository.instance.load();
    connected = await LoginService.instance.hasCASSession();
    if (!connected) {
      log.fine('User is not connected to CAS : database reset');
      Session().clear(persist: true);
    }
  }

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: connected
        ? const LoadingPage(callbackWidget: HomePage())
        : const UnconnectedHomePage(),
  );
}

Future<void> main({
  SessionRepository? sessionRepository,
  Session? session,
  LoginService? loginService,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Logger.root.onRecord.listen((record) {
    print('[${packageInfo.appName}][${record.loggerName}] - ${record.message}');
  });
  await AppConfig().loadConfig();
  final app = await buildApp();
  runApp(app);
}
