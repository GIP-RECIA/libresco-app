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
import 'package:libresco/objects/service.dart';
import 'package:libresco/objects/singletons/services_list.dart';
import 'package:libresco/services/portal_service.dart';
import 'package:libresco/ui/components/services_card.dart';
import 'package:libresco/utils/home_model.dart';
import 'package:logging/logging.dart';

class ServicesFragment extends StatefulWidget {
  final HomeModel homeModel;

  const ServicesFragment({
    super.key,
    required this.homeModel,
  });

  @override
  State<ServicesFragment> createState() => _ServicesFragment();
}

class _ServicesFragment extends State<ServicesFragment> {
  final log = Logger('_ServicesFragment');
  List<Service> renderedServices = Services().servicesList;

  void _switchPortletIsFavoriteState(int index) async {
    bool isTaskValidated = await PortalService.instance.switchPortletIsFavoriteState(renderedServices[index]);

    if (isTaskValidated) {
      final Service currService = renderedServices[index];
      setState(() {
        renderedServices[index] = currService;
      });
      widget.homeModel.notify();
    }
  }

  @override
  void initState() {
    super.initState();
    initServices();
  }

  Future<void> initServices() async {
    if (Services().servicesList.isNotEmpty) {
      return;
    }

    await PortalService.instance.getAllPortlets();

    setState(() {
      renderedServices = Services().servicesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            margin: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 15.0,
                // childAspectRatio: (1 / 1.15),
              ),
              itemCount: renderedServices.length,
              itemBuilder: (context, index) {
                final Service service = renderedServices[index];
                return ServicesCard(service, onPressed: () => _switchPortletIsFavoriteState(index));
              },
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
