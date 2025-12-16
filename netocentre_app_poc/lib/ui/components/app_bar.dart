import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netocentre_app_poc/objects/enums/user_menu_item.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool close;
  final VoidCallback onClose;
  final String title;
  final String avatarUrl;
  final ValueChanged<UserMenuItem> onUserMenu;

  const CustomAppBar({
    super.key,
    required this.close,
    required this.onClose,
    required this.title,
    required this.avatarUrl,
    required this.onUserMenu,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: close
          ? IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close),
            )
          : Container(
              padding: EdgeInsets.all(8),
              child: SvgPicture.network(
                '${AppConfig().uPortalBaseURL}/images/partners/netocentre-simple.svg',
              ),
            ),
      title: Text(title),
      actions: [
        PopupMenuButton<UserMenuItem>(
          position: PopupMenuPosition.under,
          color: Colors.white,
          icon: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          onSelected: (value) => onUserMenu(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: UserMenuItem.notification,
              child: Row(
                children: [
                  Expanded(
                    child: Text('Notifications'),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: UserMenuItem.account,
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
              value: UserMenuItem.infoEtab,
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
              value: UserMenuItem.changeEtab,
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
              value: UserMenuItem.changeAccount,
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
