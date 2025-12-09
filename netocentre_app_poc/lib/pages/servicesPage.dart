import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/entities/service.dart';
import 'package:netocentre_app_poc/pages/components/expansionTile.dart';
import 'package:netocentre_app_poc/pages/components/myAppBar.dart';
import 'package:netocentre_app_poc/pages/components/servicesCard.dart';
import 'package:netocentre_app_poc/services/portalService.dart';
import 'package:netocentre_app_poc/singletons/servicesList.dart';
import 'package:slugify/slugify.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPage();
}

class _ServicesPage extends State<ServicesPage> {
  final log = Logger('_ServicesPage');
  List<Service> renderedServices = Services().servicesList;
  String dropwdownValue = "";

  void _sortAlphabetically() {
    setState(() {
      renderedServices.sort(
        (a, b) => slugify(a.text).compareTo(slugify(b.text)),
      );
    });
  }

  void _sortUnalphabetically() {
    setState(() {
      renderedServices.sort(
        (b, a) => slugify(a.text).compareTo(slugify(b.text)),
      );
    });
  }

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

    if (Services().servicesList.isEmpty) {
      initServices();
    }
  }

  Future<void> initServices() async {
    await PortalService.instance.getAllPortlets();

    setState(() {
      renderedServices = Services().servicesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldwithIntegratedSearchBar(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  "Tous les services",
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            /// expansion tile classique  utiliser ici, adaptation du code generique trop complexeé
            const MyExpansionTile(
              "Filtres",
              dataset: [],
            ),
            Container(
              margin: const EdgeInsets.all(18),
              width: MediaQuery.of(context).size.width - 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: const Text(
                      "Trier par : ",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  DropdownMenu<String>(
                    trailingIcon: const Icon(Icons.keyboard_arrow_down),
                    selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up),
                    menuStyle: const MenuStyle(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.white),
                    ),
                    textStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    onSelected: (value) {
                      log.info("Selected service $value");
                      if (value != dropwdownValue && value != null) {
                        dropwdownValue = value;
                        switch (value) {
                          case 'a-z':
                            _sortAlphabetically();
                          case 'z-a':
                            _sortUnalphabetically();
                          default:
                            {}
                        }
                      }
                    },
                    dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                      DropdownMenuEntry(
                        label: "Popularité",
                        value: "popularite",
                      ),
                      DropdownMenuEntry(
                        label: "Plus récents",
                        value: "plus_recents",
                      ),
                      DropdownMenuEntry(
                        label: "A-Z",
                        value: "a-z",
                      ),
                      DropdownMenuEntry(
                        label: "Z-A",
                        value: "z-a",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0,
                  childAspectRatio: (1 / 1.15),
                ),
                itemCount: renderedServices.length,
                itemBuilder: (context, index) {
                  final Service service = renderedServices[index];
                  return ServicesCard(service,
                      onPressed: () => _switchPortletIsFavoriteState(index));
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
