import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class NavBar extends StatefulWidget {
  final ValueChanged<int> onDestinationSelected;

  const NavBar({
    super.key,
    required this.onDestinationSelected,
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

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onDestinationSelected(index);
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
      onDestinationSelected: _onDestinationSelected,
    );
  }
}
