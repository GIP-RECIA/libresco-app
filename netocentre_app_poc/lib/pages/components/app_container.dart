import 'package:flutter/material.dart';
import 'package:netocentre_app_poc/pages/components/app_bar.dart';
import 'package:netocentre_app_poc/pages/components/nav_bar.dart';
import 'package:netocentre_app_poc/pages/unconnected_home_page.dart';
import 'package:netocentre_app_poc/singletons/account.dart';
import 'package:netocentre_app_poc/singletons/app_config.dart';
import 'package:netocentre_app_poc/singletons/services_list.dart';
import 'package:netocentre_app_poc/singletons/session.dart';
import 'package:netocentre_app_poc/singletons/user_info.dart';

class AppContainer extends StatefulWidget {
  final bool? appBarBack;
  final VoidCallback? onBack;
  final String? appBarTitle;
  final Widget body;
  final bool? bottomNavigation;
  final ValueChanged<int>? onItemTapped;

  const AppContainer({
    super.key,
    this.appBarBack,
    this.onBack,
    this.appBarTitle,
    required this.body,
    this.bottomNavigation,
    this.onItemTapped,
  });

  @override
  State<AppContainer> createState() => _AppContainer();
}

class _AppContainer extends State<AppContainer> {
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
        onNotification: () => _openNotifications(context),
        onAccount: () => _openMyAccount(context),
        onInfoEtab: () => _openInfoEtab(context),
        onChangeEtab: () => _openChangeEtab(context),
        onChangeAccount: () => _changeAccount(context),
      ),
      body: widget.body,
      bottomNavigationBar: widget.bottomNavigation ?? true
          ? NavBar(
              onItemTapped: (index) => widget.onItemTapped?.call(index),
            )
          : null,
    );
  }
}
