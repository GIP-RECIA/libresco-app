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
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:libresco/ui/components/app_container.dart';
import 'package:libresco/ui/components/home_fragment.dart';
import 'package:libresco/ui/components/services_fragment.dart';
import 'package:libresco/utils/home_model.dart';
import 'package:logging/logging.dart';

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
