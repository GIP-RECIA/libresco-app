import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:netocentre_app_poc/pages/components/accountCard.dart';
import 'package:netocentre_app_poc/pages/homePage.dart';
import 'package:netocentre_app_poc/pages/loadingPage.dart';
import 'package:netocentre_app_poc/pojo/accountData.dart';
import 'package:netocentre_app_poc/repositories/SessionRepository.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/singletons/account.dart';
import 'package:netocentre_app_poc/singletons/appConfig.dart';
import 'package:netocentre_app_poc/singletons/session.dart';
import 'package:netocentre_app_poc/utils/AuthenticationInAppBrowser.dart';

class UnconnectedHomePage extends StatefulWidget {
  const UnconnectedHomePage({super.key});

  @override
  State<UnconnectedHomePage> createState() => _UnconnectedHomePage();
}

class _UnconnectedHomePage extends State<UnconnectedHomePage> {
  List<AccountData> accounts = List.empty(growable: true);
  late InAppBrowser browser;

  final settings = InAppBrowserClassSettings(
    browserSettings: InAppBrowserSettings(hideToolbarTop: true),
    webViewSettings: InAppWebViewSettings(
      javaScriptEnabled: true,
      isInspectable: kDebugMode,
      useShouldInterceptRequest: true,
      userAgent: AppConfig().userAgent,
      supportZoom: false,
    ),
  );

  @override
  void initState() {
    super.initState();
    browser = AuthenticationInAppBrowser(context);
    initAccounts();
  }

  Future<void> initAccounts() async {
    List<Map<String, Object?>> profiles =
        await SessionRepository.instance.getProfilesList();

    final loadedAccounts = profiles
        .map(
          (p) => AccountData(
            id: p['id'] as int,
            name: p['name'] as String,
            avatarUrl: AppConfig().uPortalBaseURL + (p['picture'] as String),
          ),
        )
        .toList();

    setState(() {
      accounts = loadedAccounts;
    });
  }

  Future<void> _openAccount(BuildContext context, AccountData account) async {
    bool connected = false;
    Account().setId(account.id.toString());
    await SessionRepository.instance.getCookiesInDB();
    connected = await LoginService.instance.hasCASSession();
    if (!connected) {
      Session().reset(flush: true);
      browser.openUrlRequest(
          urlRequest: URLRequest(
            url: WebUri(
              '${AppConfig().casBaseURL}/cas/login'
              '?service=${AppConfig().serviceURL}',
            ),
          ),
          settings: settings);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoadingPage(callbackWidget: HomePage()),
        ),
      );
    }
  }

  Future<void> _logoutAccount(BuildContext context, AccountData account) async {
    Account().setId(account.id.toString());
    await SessionRepository.instance.getCookiesInDB();
    await LoginService.instance.logout();
    Session().reset();
    Account().setId('');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Déconnexion ${account.name}")),
    );
  }

  Future<void> _deleteAccount(BuildContext context, AccountData account) async {
    Account().setId(account.id.toString());
    await SessionRepository.instance.getCookiesInDB();
    await LoginService.instance.logout();
    await SessionRepository.instance.deleteCookiesForCurrentProfile();
    Session().reset();
    Account().setId('');

    await initAccounts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Supprimer ${account.name}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const FlutterLogo(size: 80),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return AccountCard(
                        title: account.name,
                        subtitle: null,
                        avatarUrl: account.avatarUrl,
                        onTap: () => _openAccount(context, account),
                        onDelete: () => _deleteAccount(context, account),
                        onLogout: () => _logoutAccount(context, account),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    browser.openUrlRequest(
                      urlRequest: URLRequest(
                        url: WebUri(
                          '${AppConfig().casBaseURL}/cas/login'
                          '?service=${AppConfig().serviceURL}',
                        ),
                      ),
                      settings: settings,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter un compte"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
