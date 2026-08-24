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
          label: 'Accueil',
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
