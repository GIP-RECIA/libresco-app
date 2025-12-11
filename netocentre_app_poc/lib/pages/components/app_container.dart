import 'package:flutter/material.dart';
import 'package:netocentre_app_poc/entities/service.dart';
import 'package:netocentre_app_poc/pages/components/app_bar.dart';
import 'package:netocentre_app_poc/pages/components/nav_bar.dart';
import 'package:netocentre_app_poc/pages/service_web_view.dart';
import 'package:netocentre_app_poc/pages/unconnected_home_page.dart';
import 'package:netocentre_app_poc/services/login_service.dart';
import 'package:netocentre_app_poc/singletons/account.dart';
import 'package:netocentre_app_poc/singletons/app_config.dart';
import 'package:netocentre_app_poc/singletons/services_list.dart';
import 'package:netocentre_app_poc/singletons/session.dart';
import 'package:netocentre_app_poc/singletons/user_info.dart';

class AppContainer extends StatefulWidget {
  final Widget body;
  final ValueChanged<int>? onItemTapped;

  const AppContainer({
    super.key,
    required this.body,
    this.onItemTapped,
  });

  @override
  State<AppContainer> createState() => _AppContainer();
}

class _AppContainer extends State<AppContainer> {
  bool _showSearchBar = false;
  final List<Service> _allItems = Services().servicesList;
  List<Service> _filteredItems = [];

  void _filterSearchResults(String query) {
    setState(() {
      _filteredItems = _allItems
          .where(
            (item) => item.text.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _filteredItems.clear();
      }
    });
  }

  void _openNotifications(BuildContext context) {}

  void _openMyAccount(BuildContext context) {}

  void _openInfoEtab(BuildContext context) {}

  void _openChangeEtab(BuildContext context) {}

  void _changeAccount(BuildContext context) {
    Session().clear();
    Account().clear();
    Services().setServicesList([]);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const UnconnectedHomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        showSearchBar: _showSearchBar,
        toggleSearchBar: _toggleSearchBar,
        onSearch: _filterSearchResults,
        schoolTitle: 'Lycée fictif',
        avatarUrl: AppConfig().uPortalBaseURL + UserInfo().picture,
        onNotification: () => _openNotifications(context),
        onAccount: () => _openMyAccount(context),
        onInfoEtab: () => _openInfoEtab(context),
        onChangeEtab: () => _openChangeEtab(context),
        onChangeAccount: () => _changeAccount(context),
      ),
      body: Stack(
        children: [
          widget.body,
          if (_showSearchBar && _filteredItems.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height:
                    (_filteredItems.length < 3 ? _filteredItems.length : 3) *
                        60.0,
                // Multiple de 60 - max 180 pour 3 affichés en simultané
                color: Colors.white,
                // Couleur de fond pour la liste
                child: _buildSearchResultsListView(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavBar(
        onItemTapped: (index) => widget.onItemTapped?.call(index),
      ),
    );
  }

  // TODO: generate list from search in the same way than normal list
  Widget _buildSearchResultsListView() {
    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final Service service = _filteredItems[index];
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xfff3f1f1),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          margin: const EdgeInsets.fromLTRB(8, 3, 8, 3),
          child: ListTile(
            title: Text(_filteredItems[index].text),
            onTap: () async {
              if (await LoginService.instance.hasCASSession() && await LoginService.instance.isAuthorizedByUPortal()) {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceWebview(
                        text: service.text,
                        uri: service.serviceUri,
                        fname: service.fname!,
                        inPortal: service.isAuthByUPortal,
                      ),
                    ),
                  );
                }
              } else {
                Session().clear(persist: true);
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnconnectedHomePage(),
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}
