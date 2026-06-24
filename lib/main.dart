import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/session.dart';
import 'package:libresco/repositories/session_repository.dart';
import 'package:libresco/services/login_service.dart';
import 'package:libresco/ui/pages/home_page.dart';
import 'package:libresco/ui/pages/loading_page.dart';
import 'package:libresco/ui/pages/unconnected_home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'firebase_options.dart';

final log = Logger('main');

void initNotifications(){
  // Called when a notification is received with the app open
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notif = message.notification;
    if (notif != null) {
      print("Notification received : ${message.data} ${notif.body} ${notif.title}");
    }
  });
  // Called when the app is opened with a click on a notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    RemoteNotification? notif = message.notification;
    if (notif != null) {
      print("App was opened via notification ${message.data} ${notif.body} ${notif.title}");
    }
  });
}

Future<Widget> buildApp() async {
  log.fine('Starting app...');
  bool connected = false;
  List<Map<String, Object?>> profiles =
      await SessionRepository.instance.getProfilesList();
  if (profiles.length == 1) {
    Account().setId(profiles[0]['id'] as int);
    if (profiles[0]['domain'] != null) {
      Account().setDomain(profiles[0]['domain'] as String);
    } else {
      log.warning("There was an error when loading the domain !");
    }
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initNotifications();
  Logger.root.level = Level.ALL;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Logger.root.onRecord.listen((record) {
    print('[${packageInfo.appName}][${record.loggerName}] - ${record.message}');
  });
  await AppConfig().loadConfig();
  final app = await buildApp();
  runApp(app);
}
