import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/ui/components/app_container.dart';
import 'package:netocentre_app_poc/ui/components/home_fragment.dart';
import 'package:netocentre_app_poc/ui/components/services_fragment.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final log = Logger('_HomePage');
  final homeKeepAlive = InAppWebViewKeepAlive();
  int _currentFragment = 0;

  @override
  void initState() {
    super.initState();
  }

  void _setCurrentFragment(int index) {
    setState(() {
      _currentFragment = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      body: <Widget>[
        HomeFragment(keepAlive: homeKeepAlive),
        const ServicesFragment(),
      ][_currentFragment],
      onDestinationSelected: _setCurrentFragment,
    );
  }
}
