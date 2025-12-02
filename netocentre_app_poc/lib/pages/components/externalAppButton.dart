import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';

class ExternalAppButton extends StatelessWidget {
  final String text;
  final String androidPackageName;
  final String iosUrlScheme;
  final String appStoreLink;

  const ExternalAppButton(
      {required this.text,
      required this.androidPackageName,
      required this.iosUrlScheme,
      required this.appStoreLink,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async => {
              await LaunchApp.openApp(
                  androidPackageName: androidPackageName,
                  iosUrlScheme: iosUrlScheme,
                  // there may be no UrlScheme, and/or they may not be known
                  appStoreLink: appStoreLink)
            },
        child: Text(text));
  }
}
