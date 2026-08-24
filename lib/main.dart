// Copyright (C) 2023 GIP-RECIA, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/session.dart';
import 'package:libresco/repositories/session_repository.dart';
import 'package:libresco/services/login_service.dart';
import 'package:libresco/ui/pages/home_page.dart';
import 'package:libresco/ui/pages/loading_page.dart';
import 'package:libresco/ui/pages/unconnected_home_page.dart';
import 'package:libresco/utils/sanitizer.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'firebase_options.dart';
import 'objects/singletons/crash_reporter.dart';

final log = Logger('main');

void initNotifications() {
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
    "libresco_channel",
    "Notifications",
    description: "Notifications de l'application libresco",
  );
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@drawable/notification');
  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );
  notifications.initialize(settings: settings);
  notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);
  NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      notificationChannel.id,
      notificationChannel.name,
      channelDescription: notificationChannel.description,
    ),
  );
  // Called when a notification is received with the app open
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final RemoteNotification? notif = message.notification;
    if (notif == null) {
      log.fine('Received a message without notification payload');
      return;
    }
    log.info("Notification received : ${notif.title} ${notif.body}");
    notifications.show(
      id: message.hashCode,
      title: notif.title,
      body: notif.body,
      notificationDetails: notificationDetails,
    );
  });
  // Called when the app is opened with a click on a notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    RemoteNotification? notif = message.notification;
    if (notif != null) {
      log.fine("App was opened via notification ${message.data} ${notif.body} ${notif.title}");
    }
  });
}

Future<Widget> buildApp() async {
  log.fine('Starting app...');
  bool connected = false;
  List<Map<String, Object?>> profiles = await SessionRepository.instance.getProfilesList();
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
    home: connected ? const LoadingPage(callbackWidget: HomePage()) : const UnconnectedHomePage(),
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
  await CrashReporter().init();
  initNotifications();
  Logger.root.level = Level.ALL;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Logger.root.onRecord.listen((record) {
    final message = sanitizeLogs(record.message);
    CrashReporter().log(message);
    print('[${packageInfo.appName}][${record.loggerName}] - $message');
  });
  await AppConfig().loadConfig();
  final app = await buildApp();
  runApp(app);
}
