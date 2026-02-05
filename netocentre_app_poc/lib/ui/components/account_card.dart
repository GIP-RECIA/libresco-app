import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool loggedIn;
  final String avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  const AccountCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.loggedIn,
    required this.avatarUrl,
    required this.onTap,
    required this.onDelete,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: loggedIn ? 1.0 : 0.7,
      child: GestureDetector(
        onTap: () => onTap(),
        child: Card.filled(
          color: loggedIn ? Colors.white : Colors.grey.shade100,
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
                if (loggedIn)
                  PopupMenuItem(
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
      ),
    );
  }
}
