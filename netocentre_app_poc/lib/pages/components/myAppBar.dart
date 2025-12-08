import 'package:flutter/material.dart';
import 'package:netocentre_app_poc/entities/service.dart';
import 'package:netocentre_app_poc/pages/components/navBar.dart';
import 'package:netocentre_app_poc/pages/serviceWebviews/casServiceWebview.dart';
import 'package:netocentre_app_poc/pages/serviceWebviews/uPortalServiceWebview.dart';
import 'package:netocentre_app_poc/pages/unconnectedHomePage.dart';
import 'package:netocentre_app_poc/services/loginService.dart';
import 'package:netocentre_app_poc/singletons/servicesList.dart';
import 'package:netocentre_app_poc/singletons/session.dart';

// TODO: call from unconnected home page needs some modification
class ScaffoldwithIntegratedSearchBar extends StatefulWidget {
  final Widget child; // Le contenu principal de la page

  const ScaffoldwithIntegratedSearchBar({super.key, required this.child});

  @override
  State<ScaffoldwithIntegratedSearchBar> createState() =>
      _ScaffoldwithIntegratedSearchBar();
}

class _ScaffoldwithIntegratedSearchBar
    extends State<ScaffoldwithIntegratedSearchBar> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomSearchAppBar(
        showSearchBar: _showSearchBar,
        toggleSearchBar: _toggleSearchBar,
        onSearch: _filterSearchResults,
        schoolTitle: "Lycée fictif",
      ),
      body: Stack(
        children: [
          widget.child,
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
      bottomNavigationBar: const NavBar(),
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
              if (service.isAuthByUPortal) {
                if (await LoginService.instance.isAuthorizedByUPortal()) {
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UPortalServiceWebview(
                          text: service.text,
                          uri: service.serviceUri,
                        ),
                      ),
                    );
                  }
                } else {
                  Session().reset(flush: true);
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnconnectedHomePage(),
                      ),
                    );
                  }
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CASServiceWebview(
                      text: service.text,
                      uri: service.serviceUri,
                      fname: service.fname!,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class CustomSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showSearchBar;
  final VoidCallback toggleSearchBar;
  final Function(String) onSearch;
  final String schoolTitle;

  const CustomSearchAppBar({
    super.key,
    required this.showSearchBar,
    required this.toggleSearchBar,
    required this.onSearch,
    required this.schoolTitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: !showSearchBar
          ? Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.motion_photos_on_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clicked on App Logo Button'),
                      ),
                    );
                  },
                );
              },
            )
          : null,
      title: showSearchBar
          ? TextField(
              decoration: const InputDecoration(
                hintText: 'Recherche...',
              ),
              onChanged: onSearch,
            )
          : Text(schoolTitle),
      actions: [
        IconButton(
          icon: Icon(showSearchBar ? Icons.close : Icons.search),
          onPressed: toggleSearchBar,
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Clicked on Info Button'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String schoolTitle;

  const MyAppBar(this.schoolTitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.motion_photos_on_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clicked on App Logo Button'),
                  ),
                );
              },
            );
          },
        ),
        title: Text(schoolTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clicked on Info Button'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clicked on Search Button'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
