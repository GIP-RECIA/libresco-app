import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class NavBar extends StatefulWidget {
  final ValueChanged<int> onItemTapped;

  const NavBar({
    super.key,
    required this.onItemTapped,
  });

  @override
  State<NavBar> createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  final log = Logger('_NavBar');
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view),
          label: 'Services',
        ),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
    );
  }
}
