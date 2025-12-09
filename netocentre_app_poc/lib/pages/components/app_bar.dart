import 'package:flutter/material.dart';

class CustomSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showSearchBar;
  final VoidCallback toggleSearchBar;
  final Function(String) onSearch;
  final String schoolTitle;
  final String avatarUrl;
  final VoidCallback onNotification;
  final VoidCallback onAccount;
  final VoidCallback onInfoEtab;
  final VoidCallback onChangeEtab;
  final VoidCallback onChangeAccount;

  const CustomSearchAppBar({
    super.key,
    required this.showSearchBar,
    required this.toggleSearchBar,
    required this.onSearch,
    required this.schoolTitle,
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
      backgroundColor: Colors.white,
      leading: !showSearchBar
          ? Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.motion_photos_on_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clicked on App Logo Button'),
                      ),
                    );
                  },
                );
              },
            )
          : null,
      title: showSearchBar
          ? TextField(
              decoration: const InputDecoration(
                hintText: 'Recherche...',
              ),
              onChanged: onSearch,
            )
          : Text(schoolTitle),
      actions: [
        // IconButton(
        //   icon: Icon(showSearchBar ? Icons.close : Icons.search),
        //   onPressed: toggleSearchBar,
        // ),
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
