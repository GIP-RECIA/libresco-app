import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:netocentre_app_poc/objects/pojo/account_data.dart';
import 'package:netocentre_app_poc/objects/singletons/account.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/repositories/session_repository.dart';
import 'package:netocentre_app_poc/services/login_service.dart';
import 'package:netocentre_app_poc/ui/components/account_card.dart';
import 'package:netocentre_app_poc/ui/pages/home_page.dart';
import 'package:netocentre_app_poc/ui/pages/loading_page.dart';
import 'package:netocentre_app_poc/utils/authentication_in_app_browser.dart';

class UnconnectedHomePage extends StatefulWidget {
  const UnconnectedHomePage({
    super.key,
  });

  @override
  State<UnconnectedHomePage> createState() => _UnconnectedHomePage();
}

class _UnconnectedHomePage extends State<UnconnectedHomePage> {
  List<AccountData> accounts = List.empty(growable: true);
  late InAppBrowser browser;

  final InAppBrowserSettings _browserSettings = InAppBrowserSettings(
    hideToolbarTop: true,
  );
  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    userAgent: AppConfig().userAgent,
    supportZoom: false,
    cacheEnabled: AppConfig().cache,
    useShouldInterceptRequest: true,
  );

  @override
  void initState() {
    super.initState();
    browser = AuthenticationInAppBrowser(context);
    initAccounts();
  }

  Future<void> initAccounts() async {
    List<Map<String, Object?>> profiles = await SessionRepository.instance.getProfilesList();

    final loadedAccounts = profiles
        .map(
          (p) => AccountData(
            id: p['id'] as int,
            name: (p['name'] ?? '') as String,
            currentEtabName: (p['currentEtabName'] ?? '') as String,
            domain: (p['domain'] ?? '') as String,
            avatarUrl: Account().getBaseUrl() + ((p['picture'] ?? '') as String),
            lastLogin: p['lastLogin']==null ? 0 : p['lastLogin'] as int,
            firstLogin: p['firstLogin']==null ? 0 : p['firstLogin'] as int,
          ),
        )
        .toList();

    setState(() {
      accounts = loadedAccounts;
    });
  }

  void _openCasBrowser() {
    browser.openUrlRequest(
      urlRequest: URLRequest(
        url: WebUri(
          '${AppConfig().casBaseURL}/cas/login'
          '?service=${AppConfig().serviceURL}',
        ),
      ),
      settings: InAppBrowserClassSettings(
        browserSettings: _browserSettings,
        webViewSettings: _webViewSettings,
      ),
    );
  }

  Future<void> _openAccount(BuildContext context, AccountData account) async {
    bool connected = false;
    Account().setId(account.id);
    Account().setDomain(account.domain);
    await SessionRepository.instance.load();
    connected = await LoginService.instance.hasCASSession();
    if (!connected) {
      Session().clear(persist: true);
      _openCasBrowser();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoadingPage(callbackWidget: HomePage()),
        ),
      );
    }
  }

  Future<void> _logoutAccount(
    BuildContext context,
    AccountData accountData,
  ) async {
    await SessionRepository.instance.load(id: accountData.id);
    await LoginService.instance.logout(accountData.domain);
    await SessionRepository.instance.resetLastLoginTime(accountData.id);
    Session().clear();

    // TODO : refaire le rendu pour actualiser la card directement

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Déconnexion du compte ${accountData.name}')),
    );
  }

  Future<void> _deleteAccount(
    BuildContext context,
    AccountData accountData,
  ) async {
    var id = accountData.id;
    await SessionRepository.instance.load(id: id);
    await LoginService.instance.logout(accountData.domain);
    await SessionRepository.instance.deleteAll(id: id);

    await initAccounts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Suppression du compte ${accountData.name}')),
    );
  }

  void _addAccount() {
    _openCasBrowser();
  }

  bool isLoggedIn(int lastLoginTime, int firstLoginTime){
    final now = DateTime.now();
    final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTime * 1000);
    final firstLogin = DateTime.fromMillisecondsSinceEpoch(firstLoginTime * 1000);
    final differenceLast = now.difference(lastLogin);
    final differenceFirst = now.difference(firstLogin);
    return (differenceLast.inDays < AppConfig().softTimeout) && (differenceFirst.inDays < AppConfig().hardTimeout);
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
                Image.asset(
                  'assets/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return AccountCard(
                        title: account.name,
                        subtitle: account.currentEtabName,
                        loggedIn: isLoggedIn(account.lastLogin, account.firstLogin),
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
                  onPressed: _addAccount,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un compte'),
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
