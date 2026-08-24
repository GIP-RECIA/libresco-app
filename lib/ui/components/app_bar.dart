// Copyright (C) 2023 GIP-RECIA, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:libresco/objects/enums/user_menu_item.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/user_info.dart';

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
              tooltip: 'Fermer',
            )
          : Container(
              padding: EdgeInsets.all(8),
              child: SvgPicture.network(
                '${Account().getBaseUrl()}/images/partners/${AppConfig().getLogoFromDomain(Account().domain)}',
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
          tooltip: 'Menu utilisateur',
          onSelected: (value) => onUserMenu(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: UserMenuItem.notification,
              enabled: false,
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
              enabled: false,
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
              enabled: false,
              child: Row(
                children: [
                  Expanded(
                    child: Text('Informations de l\'établissement'),
                  ),
                  Icon(Icons.info),
                ],
              ),
            ),
            if (UserInfo().sirens.length > 1)
              const PopupMenuItem(
                value: UserMenuItem.changeEtab,
                enabled: true,
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
