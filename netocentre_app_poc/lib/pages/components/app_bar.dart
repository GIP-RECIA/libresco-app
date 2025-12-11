import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netocentre_app_poc/singletons/app_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool back;
  final VoidCallback onBack;
  final String title;
  final String avatarUrl;
  final VoidCallback onNotification;
  final VoidCallback onAccount;
  final VoidCallback onInfoEtab;
  final VoidCallback onChangeEtab;
  final VoidCallback onChangeAccount;

  const CustomAppBar({
    super.key,
    required this.back,
    required this.onBack,
    required this.title,
    required this.avatarUrl,
    required this.onNotification,
    required this.onAccount,
    required this.onInfoEtab,
    required this.onChangeEtab,
    required this.onChangeAccount,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: back
          ? IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back),
            )
          : Container(
              padding: EdgeInsets.all(8),
              child: SvgPicture.network(
                '${AppConfig().uPortalBaseURL}/images/partners/netocentre-simple.svg',
              ),
            ),
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          color: Colors.white,
          icon: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          onSelected: (value) {
            if (value == 'notification') onNotification();
            if (value == 'account') onAccount();
            if (value == 'info-etab') onInfoEtab();
            if (value == 'change-etab') onChangeEtab();
            if (value == 'change-account') onChangeAccount();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'notification',
              child: Row(
                children: [
                  Expanded(
                    child: Text('Notifications'),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'account',
              child: Row(
                children: [
                  Expanded(
                    child: Text('Mon profil'),
                  ),
                  Icon(Icons.person),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'info-etab',
              child: Row(
                children: [
                  Expanded(
                    child: Text('Informations de l\'établissement'),
                  ),
                  Icon(Icons.info),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'change-etab',
              child: Row(
                children: [
                  Expanded(
                    child: Text('Changer d\'établissement'),
                  ),
                  Icon(Icons.swap_horiz),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'change-account',
              child: Row(
                children: [
                  Expanded(
                    child: Text('Changer de compte'),
                  ),
                  Icon(Icons.swap_horiz),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
