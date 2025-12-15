import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/service.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/services_list.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/objects/singletons/user_info.dart';
import 'package:netocentre_app_poc/services/login_service.dart';

class PortalService {
  final log = Logger('PortalService');

  PortalService._privateConstructor();

  static final PortalService _instance = PortalService._privateConstructor();

  static PortalService get instance => _instance;

  Future<void> getAllPortlets() async {
    log.fine('Getting portlets...');

    final client = IOClient(HttpClient());

    Uri request = Uri.https(
      AppConfig().uPortalHost,
      '/portail/api/v4-3/dlm/portletRegistry.json',
      {
        'category': 'All categories',
      },
    );

    log.finer('Getting portlet request : $request');
    log.finer(
      '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}',
    );

    if (await LoginService.instance.isAuthorizedByUPortal()) {
      final http.Response res = await client.get(
        request,
        headers: <String, String>{
          'Cookie':
              '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}; '
                  '${AppConfig().portalIDCookieName}=${Session().IDPortalCookie}',
          'Host': AppConfig().uPortalHost
        },
      );

      if (res.statusCode == 200) {
        /// Parse json and get portlets fname
        final dynamic jsonSubcategories =
            json.decode(res.body)['registry']['categories'][0]['subcategories'];

        Set<String> portletsSet = {};
        List<Service> servicesList = [];
        List<Service> favoritesList = [];

        for (var subcategory in jsonSubcategories) {
          for (var portlet in subcategory['portlets']) {
            if (!portletsSet.contains(portlet['fname'])) {
              log.finer(
                'portlet ${portlet['title']} favorite : ${portlet['favorite']}',
              );

              String portletIconUri = '';

              // get icon  uri
              if (portlet['parameters'].containsKey('mobileIconUrl')) {
                portletIconUri =
                    portlet['parameters']['mobileIconUrl']['value'];
                log.finer(
                  'portlet ${portlet['title']} icon url : $portletIconUri',
                );
              }

              // if auth directly on CAS
              if (portlet['parameters']
                  .containsKey('alternativeMaximizedLink')) {
                String? serviceUri = serviceUriParser(
                  portlet['parameters']['alternativeMaximizedLink']['value'],
                );
                if (serviceUri != null) {
                  servicesList.add(
                    Service.CASBased(
                      id: portlet['id'],
                      text: portlet['title'],
                      serviceUri: serviceUri,
                      iconUri: portletIconUri,
                      isFavorite: portlet['favorite'],
                      fname: portlet['fname'],
                    ),
                  );
                  if (portlet['favorite']) {
                    favoritesList.add(
                      Service.CASBased(
                        id: portlet['id'],
                        text: portlet['title'],
                        serviceUri: serviceUri,
                        iconUri: portletIconUri,
                        isFavorite: portlet['favorite'],
                        fname: portlet['fname'],
                      ),
                    );
                  }
                } else {
                  log.warning('service uri is null for ${portlet['title']}');
                }
              } else {
                servicesList.add(
                  Service.UPortalBased(
                    id: portlet['id'],
                    text: portlet['title'],
                    serviceUri: portlet['fname'],
                    iconUri: portletIconUri,
                    isFavorite: portlet['favorite'],
                    fname: portlet['fname'],
                  ),
                );
                if (portlet['favorite']) {
                  favoritesList.add(
                    Service.UPortalBased(
                      id: portlet['id'],
                      text: portlet['title'],
                      serviceUri: portlet['fname'],
                      iconUri: portletIconUri,
                      isFavorite: portlet['favorite'],
                      fname: portlet['fname'],
                    ),
                  );
                }
              }
              portletsSet = {
                ...portletsSet,
                portlet['fname'],
              };
            }
          }
        }

        Services().setServicesList(servicesList);
        Services().setFavoritesList(favoritesList);
        log.fine(
          'Final list of services :${Services().servicesList.toString()}',
        );
      } else {
        log.warning('Got an abnormal ${res.statusCode} response status code !');
      }
    } else {
      log.warning('${AppConfig().portalCookieName} Empty !');
    }
  }

  Future<bool> switchPortletIsFavoriteState(Service service) async {
    log.info('Switching portlet favorite state for ${service.fname}');

    // Switch 'is favorite' attribute state
    bool apiResponseResult = await requestSwitchPortletIsFavoriteState(service);

    if (apiResponseResult) {
      List<Service> currentServicesList = Services().servicesList;
      List<Service> currentFavoritesList = Services().favoritesList;
      currentServicesList.removeWhere(
        (indexedService) => indexedService.id == service.id,
      );
      service.isFavorite = !(service.isFavorite);

      // if it was in favorites list
      if (!(service.isFavorite)) {
        // remove from favorites list
        currentFavoritesList.removeWhere(
          (indexedService) => indexedService.id == service.id,
        );
      } else {
        // add to favorites list
        currentFavoritesList.add(service);
      }

      // update the singleton
      Services().setFavoritesList(currentFavoritesList);
      currentServicesList.add(service);
      Services().setServicesList(currentServicesList);

      return true;
    }

    return false;
  }

  Future<bool> requestSwitchPortletIsFavoriteState(Service service) async {
    log.info('Requesting API to switch portlet is favorite state');

    final client = IOClient(HttpClient());

    Uri request = Uri.https(
      AppConfig().uPortalHost,
      '/portail/api/layout',
      {
        'action': service.isFavorite ? 'removeFavorite' : 'addFavorite',
        'channelId': service.id.toString()
      },
    );

    log.finer('Getting portlet request : $request');
    log.finer(
        '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}');

    if (await LoginService.instance.isAuthorizedByUPortal()) {
      final http.Response res = await client.post(
        request,
        headers: <String, String>{
          'Cookie':
              '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}; '
                  '${AppConfig().portalIDCookieName}=${Session().IDPortalCookie}',
          'Host': AppConfig().uPortalHost
        },
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        log.warning('Got an abnormal ${res.statusCode} response status code !');
      }
    }

    return false;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    log.info('Getting user infos');

    final client = IOClient(HttpClient());
    Uri request = Uri.https(
      AppConfig().uPortalHost,
      '/portail/api/v5-1/userinfo',
      {
        'claims': 'private,picture,name,ESCOSIRENCourant,ESCOSIREN',
        'groups': ''
      },
    );

    log.finer('getting portlet request : $request');
    log.finer(
      '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}',
    );

    final http.Response res = await client.get(
      request,
      headers: <String, String>{
        'Cookie':
            '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}; '
                '${AppConfig().portalIDCookieName}=${Session().IDPortalCookie}',
        'Host': AppConfig().uPortalHost
      },
    );

    if (res.statusCode == 200) {
      /// Decode base64 and parse json
      log.finest('Body of response is ${res.body}');

      String base64url = res.body.split('.')[1];
      base64url = base64url.replaceAll('-', '+').replaceAll('_', '/');
      if (base64url.length % 4 != 0) {
        base64url = base64url + ('=' * (4 - (base64url.length % 4)));
      }
      log.finest('Extracted base64 $base64url');

      final String decodedBase64 = utf8.decode(base64.decode(base64url));
      log.finer('Decoded base64 $decodedBase64');

      return json.decode(decodedBase64);
    } else {
      log.warning('Got an abnormal ${res.statusCode} response status code !');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getInfoEtab(String siren) async {
    log.info('Getting etab name from change-etablissement');
    log.info(siren.runtimeType);

    final client = IOClient(HttpClient());
    Uri request = Uri.https(
      AppConfig().uPortalHost,
      '${AppConfig().paramEtabContextPath}/rest/v2/structures/structs/',
      {
        'ids': siren,
      },
    );
    log.finer('Making a request to etab API : $request');
    final http.Response res = await client.get(request);
    if (res.statusCode == 200) {
      var rawEtabData = json.decode(res.body);
      return rawEtabData[siren];
    } else {
      return null;
    }
  }

  Future<bool> loadUserInfo() async {
    log.info('Loading user info');
    var rawUserInfo = await getUserInfo();
    if (rawUserInfo == null) return false;
    var rowEtabInfo = await getInfoEtab(rawUserInfo['ESCOSIRENCourant'][0]);
    if (rowEtabInfo == null) return false;
    rawUserInfo['currentEtabName'] = rowEtabInfo["displayName"];
    UserInfo().fromMap(rawUserInfo);
    UserInfo().setUid(rawUserInfo['sub'] ?? '');
    UserInfo().update();
    return true;
  }

  /// uri parser for services who are based on cas auth
  String? serviceUriParser(String completeUri) {
    return Uri.parse(completeUri).queryParameters['service'];
  }
}
