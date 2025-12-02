import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/pages/homePage.dart';
import 'package:netocentre_app_poc/pages/servicesPage.dart';
import 'package:netocentre_app_poc/pages/unconnectedHomePage.dart';
import 'package:netocentre_app_poc/repositories/tokenRepository.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/services/portalService.dart';
import 'package:netocentre_app_poc/singletons/appConfig.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';
import 'package:netocentre_app_poc/singletons/userInfo.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  final log = Logger('_NavBar');
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  String pictureUri = "";

  @override
  void initState() {
    super.initState();

    if (UserInfo().firstname == "") {
      log.warning("User info should be loaded but is not !");
      PortalService.instance.loadUserInfo();
    }
    // TODO : pictureUri
    pictureUri =
        "https://${AppConfig().uPortalBaseURL}${UserInfo().pictureURI}";
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
      ),
      menuChildren: <Widget>[
        MenuItemButton(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Changer d'établissement"),
              Icon(Icons.swap_horiz_outlined),
            ],
          ),
          onPressed: () => {},
        ),
        MenuItemButton(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Mon profil"),
              Icon(Icons.settings),
            ],
          ),
          onPressed: () => {},
        ),
        MenuItemButton(
          key: const Key("logout"),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Déconnexion",
                style: TextStyle(color: Colors.red),
              ),
              Icon(
                Icons.logout_outlined,
                color: Colors.red,
              ),
            ],
          ),
          onPressed: () async {
            await LoginService.instance.logout();
            await TokenRepository.instance.deleteCookiesForCurrentProfile();
            TokenManager().reset();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const UnconnectedHomePage()),
              );
            }
          },
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return BottomAppBar(
          height: MediaQuery.of(context).size.height * 0.07,
          color: const Color(0xFF2c2c2c),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                key: const Key("homeButton"),
                icon: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                },
              ),
              IconButton(
                key: const Key("serviceList"),
                icon: const Icon(
                  Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ServicesPage()));
                },
              ),
              IconButton(
                  key: const Key("profileInfo"),
                  icon: const Icon(
                    Icons.account_box,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}
