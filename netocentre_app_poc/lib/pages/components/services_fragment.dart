import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/service.dart';
import 'package:netocentre_app_poc/objects/singletons/services_list.dart';
import 'package:netocentre_app_poc/pages/components/services_card.dart';
import 'package:netocentre_app_poc/services/portal_service.dart';

class ServicesFragment extends StatefulWidget {
  const ServicesFragment({super.key});

  @override
  State<ServicesFragment> createState() => _ServicesFragment();
}

class _ServicesFragment extends State<ServicesFragment> {
  final log = Logger('_ServicesFragment');
  List<Service> renderedServices = Services().servicesList;

  // String dropwdownValue = '';
  //
  // void _sortAlphabetically() {
  //   setState(() {
  //     renderedServices.sort(
  //       (a, b) => slugify(a.text).compareTo(slugify(b.text)),
  //     );
  //   });
  // }
  //
  // void _sortUnalphabetically() {
  //   setState(() {
  //     renderedServices.sort(
  //       (b, a) => slugify(a.text).compareTo(slugify(b.text)),
  //     );
  //   });
  // }

  void _switchPortletIsFavoriteState(int index) async {
    bool isTaskValidated = await PortalService.instance
        .switchPortletIsFavoriteState(renderedServices[index]);

    if (isTaskValidated) {
      final Service currService = renderedServices[index];
      setState(() {
        renderedServices[index] = currService;
      });
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
                return ServicesCard(service,
                    onPressed: () => _switchPortletIsFavoriteState(index));
              },
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
