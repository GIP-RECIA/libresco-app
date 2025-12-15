import 'package:flutter/material.dart';
import 'package:netocentre_app_poc/objects/enums/user_menu_item.dart';
import 'package:netocentre_app_poc/objects/singletons/account.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/services_list.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/objects/singletons/user_info.dart';
import 'package:netocentre_app_poc/ui/components/app_bar.dart';
import 'package:netocentre_app_poc/ui/components/nav_bar.dart';
import 'package:netocentre_app_poc/ui/pages/unconnected_home_page.dart';

class AppContainer extends StatefulWidget {
  final bool? appBarBack;
  final VoidCallback? onBack;
  final String? appBarTitle;
  final Widget body;
  final bool? bottomNavigation;
  final ValueChanged<int>? onDestinationSelected;

  const AppContainer({
    super.key,
    this.appBarBack,
    this.onBack,
    this.appBarTitle,
    required this.body,
    this.bottomNavigation,
    this.onDestinationSelected,
  });

  @override
  State<AppContainer> createState() => _AppContainer();
}

class _AppContainer extends State<AppContainer> {
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

  void _openChangeEtab(BuildContext context) {}

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
        back: widget.appBarBack ?? false,
        onBack: () => widget.onBack?.call(),
        title: widget.appBarTitle ?? UserInfo().currentEtabName,
        avatarUrl: AppConfig().uPortalBaseURL + UserInfo().picture,
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
