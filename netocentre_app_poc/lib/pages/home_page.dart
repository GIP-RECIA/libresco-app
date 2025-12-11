import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/pages/components/app_container.dart';
import 'package:netocentre_app_poc/pages/components/home_fragment.dart';
import 'package:netocentre_app_poc/pages/components/services_fragment.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final log = Logger('_HomePage');
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  void _setCurrentPage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      body: <Widget>[
        const HomeFragment(),
        const ServicesFragment(),
      ][_currentPage],
      onItemTapped: _setCurrentPage,
    );
  }
}
