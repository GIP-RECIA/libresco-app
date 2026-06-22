import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:libresco/ui/components/app_container.dart';
import 'package:libresco/ui/components/home_fragment.dart';
import 'package:libresco/ui/components/services_fragment.dart';
import 'package:libresco/utils/home_model.dart';

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
  final HomeModel homeModel = HomeModel();

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
      body: IndexedStack(
        index: _currentFragment,
        children: [
          HomeFragment(
            keepAlive: homeKeepAlive,
            homeModel: homeModel,
          ),
          ServicesFragment(
            homeModel: homeModel,
          ),
        ],
      ),
      onDestinationSelected: _setCurrentFragment,
    );
  }
}
