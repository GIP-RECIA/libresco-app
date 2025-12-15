import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netocentre_app_poc/main.dart' as app;
import 'package:netocentre_app_poc/ui/components/services_fragment.dart';
import 'package:netocentre_app_poc/ui/pages/home_page.dart';
import 'package:netocentre_app_poc/ui/pages/unconnected_home_page.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Integration full test : login - service access - logout',
    ($) async {
      // Launch the app
      final widget = await app.buildApp();
      await $.pumpWidgetAndSettle(widget);

      // We should be in UnconnectedHomePage
      expect($(UnconnectedHomePage), findsOneWidget);

      // Click on login to display the login webview
      await $(#loginButton).tap();
      await $.pumpAndSettle();

      // Login on CAS
      await $.native.tap(Selector(resourceId: 'autres-publics'));
      await $.native.enterText(
        Selector(resourceId: 'username'),
        text: 'username',
      );
      await $.native.enterText(
        Selector(resourceId: 'password'),
        text: 'password',
      );
      await $.native.tap(Selector(resourceId: 'localAuthLoginButton'));

      // After login we should be redirected on the home page
      await $.waitUntilExists($(HomePage), timeout: const Duration(minutes: 1));
      expect($(HomePage), findsOneWidget);

      // Click on icon to obtain service list
      await $(#serviceList).tap();
      await $.pumpAndSettle();
      expect($(ServicesFragment), findsOneWidget);

      // Click on CAS service (MCE)
      await $.scrollUntilVisible(
        finder: find.byKey(const Key("Mon compte ENT")),
        delta: 150,
        maxScrolls: 30,
      );
      await $.tap(find.byKey(const Key("Mon compte ENT")));
      await $.pumpAndSettle();
      await $.native.waitUntilVisible(
        Selector(resourceId: "infoPerso:userGivenName"),
      );

      // Back to service list
      await $(#backFromWebviewButton).tap();
      await $.pumpAndSettle();
      expect($(ServicesFragment), findsOneWidget);

      // Click on a portal service (protection by soffit)
      await $.scrollUntilVisible(
        finder: find.byKey(const Key("Actualités")),
        scrollDirection: AxisDirection.up,
        delta: 150,
        maxScrolls: 30,
      );
      await $.tap(find.byKey(const Key("Actualités")));
      await $.pumpAndSettle();
      await $.native.waitUntilVisible(Selector(resourceId: "portalPageBody"));

      // Back to service list
      await $(#backFromWebviewButton).tap();
      await $.pumpAndSettle();
      expect($(ServicesFragment), findsOneWidget);

      // Click on profile info then logout
      await $(#profileInfo).tap();
      await $.pumpAndSettle();
      await $(#logout).tap();
      await $.pumpAndSettle();

      // We should be in UnconnectedHomePage
      expect($(UnconnectedHomePage), findsOneWidget);
    },
  );
}
