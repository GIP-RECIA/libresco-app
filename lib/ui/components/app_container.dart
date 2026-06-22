import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:libresco/objects/enums/user_menu_item.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/services_list.dart';
import 'package:libresco/objects/singletons/session.dart';
import 'package:libresco/objects/singletons/user_info.dart';
import 'package:libresco/services/changeetab_service.dart';
import 'package:libresco/services/portal_service.dart';
import 'package:libresco/ui/components/app_bar.dart';
import 'package:libresco/ui/components/nav_bar.dart';
import 'package:libresco/ui/pages/unconnected_home_page.dart';

import '../../services/login_service.dart';
import '../pages/home_page.dart';
import '../pages/loading_page.dart';

class AppContainer extends StatefulWidget {
  final bool? appBarClose;
  final VoidCallback? onClose;
  final String? appBarTitle;
  final Widget body;
  final bool? bottomNavigation;
  final ValueChanged<int>? onDestinationSelected;

  const AppContainer({
    super.key,
    this.appBarClose,
    this.onClose,
    this.appBarTitle,
    required this.body,
    this.bottomNavigation,
    this.onDestinationSelected,
  });

  @override
  State<AppContainer> createState() => _AppContainer();
}

class _AppContainer extends State<AppContainer> {
  final log = Logger('_AppContainer');

  late final Map<UserMenuItem, void Function(BuildContext)> _actions = {
    UserMenuItem.notification: (ctx) => _openNotifications(ctx),
    UserMenuItem.account: (ctx) => _openMyAccount(ctx),
    UserMenuItem.infoEtab: (ctx) => _openInfoEtab(ctx),
    UserMenuItem.changeEtab: (ctx) => _openChangeEtab(ctx),
    UserMenuItem.changeAccount: (ctx) => _changeAccount(ctx),
  };

  void _onUserMenu(BuildContext context, UserMenuItem value) {
    final action = _actions[value];
    if (action != null) action(context);
  }

  void _openNotifications(BuildContext context) {}

  void _openMyAccount(BuildContext context) {}

  void _openInfoEtab(BuildContext context) {}

  void _openChangeEtab(BuildContext context) async {
    log.fine("User requested change of establishment");
    // Récupération d'une soffit à jour
    var rawUserInfo = await PortalService.instance.getUserInfo(
      'private,picture,name,ESCOSIRENCourant,ESCOSIREN',
    );
    final String soffit = rawUserInfo!.$1;

    // Récupération des infos des structures
    final Map<String, dynamic>? structures =
        await PortalService.instance.getInfoEtab(UserInfo().sirens);
    log.warning(structures);
    if (structures!.length > 1) {
      // Affichage des établissements sur lesquels on peut changer en excluant l'établissement courant
      final selectedSiren = await showEtabSelector(
        context,
        structures!,
        UserInfo().currentSiren,
      );
      log.fine("User selected etab $selectedSiren");

      if (selectedSiren == null) return;
      bool result = await ChangeEtabService.instance.changeEtab(
        soffit,
        selectedSiren,
      );
      if (!result) {
        log.warning("Could not change etab because an error occured !");
      } else {
        LoginService.instance.logout(Account().domain, true);
        Session().setPortalSessionCookie('');
        Session().persist();
        // We need to wait a little bit to make sur partial logout is finished
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoadingPage(callbackWidget: HomePage()),
            ),
          );
        });
      }
    } else {
      log.fine(
        "Pas de changement d'établissement car pas de multi établissement",
      );
    }
  }

  Future<String?> showEtabSelector(
    BuildContext context,
    Map<String, dynamic> etabsMap,
    String currentSiren,
  ) async {
    final filteredEtabs = etabsMap.entries
        .where((entry) => entry.key != currentSiren)
        .map((entry) => entry.value)
        .toList();

    log.fine("List of etabs for user to change $filteredEtabs");

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Changer d'établissement"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredEtabs.length,
              itemBuilder: (context, index) {
                final etab = filteredEtabs[index];
                final siren = etab["id"] ?? etab["code"] ?? "???";
                return ListTile(
                  title: Text(
                    etab["displayName"] ?? etab["name"] ?? "Sans nom",
                  ),
                  subtitle: Text(siren),
                  onTap: () {
                    Navigator.pop(context, siren);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _changeAccount(BuildContext context) {
    Session().clear();
    Account().clear();
    Services().setServicesList([]);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const UnconnectedHomePage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        close: widget.appBarClose ?? false,
        onClose: () => widget.onClose?.call(),
        title: widget.appBarTitle ?? UserInfo().currentEtabName,
        avatarUrl: Account().getBaseUrl() + UserInfo().picture,
        onUserMenu: (value) => _onUserMenu(context, value),
      ),
      body: SafeArea(child: widget.body),
      bottomNavigationBar: widget.bottomNavigation ?? true
          ? NavBar(
              onDestinationSelected: (index) =>
                  widget.onDestinationSelected?.call(index),
            )
          : null,
    );
  }
}
