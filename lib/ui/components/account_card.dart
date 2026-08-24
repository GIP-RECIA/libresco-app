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

class AccountCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  const AccountCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.avatarUrl,
    required this.onTap,
    required this.onDelete,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card.filled(
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsetsDirectional.only(start: 16, end: 8),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            color: Colors.white,
            tooltip: 'Menu actions sur le compte',
            menuPadding: EdgeInsetsGeometry.all(0),
            onSelected: (value) {
              if (value == 'delete') onDelete();
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                    )
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
