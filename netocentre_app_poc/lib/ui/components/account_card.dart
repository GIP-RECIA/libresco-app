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
