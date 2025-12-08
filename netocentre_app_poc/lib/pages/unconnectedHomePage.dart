import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:netocentre_app_poc/pages/homePage.dart';
import 'package:netocentre_app_poc/pages/loadingPage.dart';
import 'package:netocentre_app_poc/repositories/tokenRepository.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/singletons/appConfig.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';
import 'package:netocentre_app_poc/utils/AuthenticationInAppBrowser.dart';

class UnconnectedHomePage extends StatefulWidget {
  const UnconnectedHomePage({super.key});

  @override
  State<UnconnectedHomePage> createState() => _UnconnectedHomePage();
}

class _UnconnectedHomePage extends State<UnconnectedHomePage> {
  List<Account> accounts = List.empty(growable: true);
  late InAppBrowser browser;

  final settings = InAppBrowserClassSettings(
      browserSettings: InAppBrowserSettings(hideToolbarTop: true),
      webViewSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          isInspectable: kDebugMode,
          useShouldInterceptRequest: true,
          userAgent: AppConfig().userAgent,
          supportZoom: false));

  @override
  void initState() {
    super.initState();
    browser = AuthenticationInAppBrowser(context);
    initAccounts();
  }

  Future<void> initAccounts() async {
    List<Map<String, Object?>> profiles = await TokenRepository.instance.getProfilesList();

    final loadedAccounts = profiles
        .map((p) => Account(
              id: p['id'] as int,
              name: p['name'] as String,
              establishment: '',
              avatarUrl: AppConfig().uPortalBaseURL + (p['picture'] as String),
            ))
        .toList();

    setState(() {
      accounts = loadedAccounts;
    });
  }

  Future<void> _openAccount(BuildContext context, Account account) async {
    bool connected = false;
    TokenManager().setId(account.id.toString());
    await TokenRepository.instance.getCookiesInDB();
    connected = await LoginService.instance.hasCASSession();
    if (!connected) {
      TokenManager().reset(flush: true);
      browser.openUrlRequest(
          urlRequest: URLRequest(
              url: WebUri('${AppConfig().casBaseURL}/cas/login'
                  '?service=${AppConfig().serviceURL}')),
          settings: settings);
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const LoadingPage(callbackWidget: HomePage())));
    }
  }

  Future<void> _logoutAccount(BuildContext context, Account account) async {
    TokenManager().setId(account.id.toString());
    await TokenRepository.instance.getCookiesInDB();
    await LoginService.instance.logout();
    TokenManager().reset();
    TokenManager().setId('');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Déconnexion ${account.name}")),
    );
  }

  Future<void> _deleteAccount(BuildContext context, Account account) async {
    TokenManager().setId(account.id.toString());
    await TokenRepository.instance.getCookiesInDB();
    await LoginService.instance.logout();
    await TokenRepository.instance.deleteCookiesForCurrentProfile();
    TokenManager().reset();
    TokenManager().setId('');

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
                        account: account,
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
                            url: WebUri('${AppConfig().casBaseURL}/cas/login'
                                '?service=${AppConfig().serviceURL}')),
                        settings: settings);
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

class Account {
  final int id;
  final String name;
  final String establishment;
  final String avatarUrl;

  Account({
    required this.id,
    required this.name,
    required this.establishment,
    required this.avatarUrl,
  });
}

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    required this.onDelete,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {onTap()},
      child: Card.filled(
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsetsDirectional.only(start: 16, end: 8),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(account.avatarUrl),
          ),
          title: Text(account.name),
          subtitle: Text(account.establishment),
          trailing: PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            color: Colors.white,
            menuPadding: EdgeInsetsGeometry.all(0),
            onSelected: (value) {
              if (value == 'delete') onDelete();
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [
                    Expanded(
                        child: Text(
                      "Se déconnecter",
                      style: TextStyle(color: Colors.red),
                    )),
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                    )
                  ])),
              const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        "Supprimer",
                        style: TextStyle(color: Colors.red),
                      )),
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
