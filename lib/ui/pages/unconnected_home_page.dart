import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:libresco/objects/pojo/account_data.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/session.dart';
import 'package:libresco/repositories/session_repository.dart';
import 'package:libresco/services/login_service.dart';
import 'package:libresco/ui/components/account_card.dart';
import 'package:libresco/ui/pages/home_page.dart';
import 'package:libresco/ui/pages/loading_page.dart';
import 'package:libresco/utils/authentication_in_app_browser.dart';

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
    List<Map<String, Object?>> profiles =
        await SessionRepository.instance.getProfilesList();

    final loadedAccounts = profiles
        .map(
          (p) => AccountData(
            id: p['id'] as int,
            name: (p['name'] ?? '') as String,
            currentEtabName: (p['currentEtabName'] ?? '') as String,
            domain: (p['domain'] ?? '') as String,
            avatarUrl:
                Account().getBaseUrl() + ((p['picture'] ?? '') as String),
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
    await LoginService.instance.logout(accountData.domain, false);
    Session().clear();

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
    await LoginService.instance.logout(accountData.domain, false);
    await SessionRepository.instance.deleteAll(id: id);

    await initAccounts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Suppression du compte ${accountData.name}')),
    );
  }

  void _addAccount() {
    _openCasBrowser();
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
                AspectRatio(
                    aspectRatio: 1099 / 370,
                  child: Image.asset(
                    'assets/logo.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return AccountCard(
                        title: account.name,
                        subtitle: account.currentEtabName,
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
