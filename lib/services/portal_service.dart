import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:libresco/objects/enums/user_info_loading_state.dart';
import 'package:libresco/objects/service.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/services_list.dart';
import 'package:libresco/objects/singletons/session.dart';
import 'package:libresco/objects/singletons/user_info.dart';
import 'package:libresco/services/login_service.dart';

import '../objects/singletons/account.dart';

class PortalService {
  final log = Logger('PortalService');

  PortalService._privateConstructor();

  static final PortalService _instance = PortalService._privateConstructor();

  static PortalService get instance => _instance;

  Future<void> getAllPortlets() async {
    log.fine('Getting portlets...');

    final client = IOClient(HttpClient());

    Uri request = Uri.https(
      Account().domain,
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
          'Host': Account().domain
        },
      );

      if (res.statusCode == 200) {
        Map<String, int> fnameToCategory = {};

        // Request service-info api to get categories (optional)
        try {
          Uri requestServiceInfo = Uri.https(
            Account().domain,
            '/service-info-api/api/allServices',
          );
          log.finer('Getting service-info-api request : $requestServiceInfo');

          final http.Response responseServiceInfo = await client.get(
            requestServiceInfo,
            headers: <String, String>{'Host': Account().domain},
          );

          final dynamic serviceInfo = json.decode(responseServiceInfo.body);
          for (var info in serviceInfo) {
            fnameToCategory[info["fname"]] = info["categoriePrincipale"];
          }
          log.finer("Loaded fnameToCategory : $fnameToCategory");
        } catch (e) {
          log.warning("An error occured getting service categories $e");
        }

        log.warning(fnameToCategory);

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

              int category = 0;
              if (fnameToCategory.containsKey(portlet['fname'])) {
                category = fnameToCategory[portlet['fname']]!;
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
                      category: category,
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
                        category: category,
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
                    category: category,
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
                      category: category,
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
      Account().domain,
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
          'Host': Account().domain
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

  /// Gets the userinfos in form of a tuple : (soffit, map of parsed user infos)
  Future<(String, Map<String, dynamic>)?> getUserInfo(String claims) async {
    log.info('Getting user infos');

    final client = IOClient(HttpClient());
    Uri request = Uri.https(
      Account().domain,
      '/portail/api/v5-1/userinfo',
      {
        'claims': claims,
        'groups': '',
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
        'Host': Account().domain
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

      return (res.body, json.decode(decodedBase64) as Map<String, dynamic>);
    } else {
      log.warning('Got an abnormal ${res.statusCode} response status code !');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getInfoEtab(List<String> sirens) async {
    log.info('Getting etab name from change-etablissement');

    final client = IOClient(HttpClient());
    Uri request = Uri.https(
      Account().domain,
      '${AppConfig().paramEtabContextPath}/rest/v2/structures/structs/',
      {
        'ids': sirens.join(','),
      },
    );
    log.finer('Making a request to etab API : $request');
    final http.Response res = await client.get(request);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      return null;
    }
  }

  Future<UserInfoLoadingState> loadUserInfo() async {
    log.info('Loading user info');
    // Get user infos thanks to already obtained portal cookie
    var rawUserInfo =
        await getUserInfo('private,picture,name,ESCOSIRENCourant,ESCOSIREN');
    if (rawUserInfo == null) return UserInfoLoadingState.error;
    // We only need the map here, not the soffit
    Map<String, dynamic> userInfo = rawUserInfo.$2;
    // Get the current siren and make a request to paramuseretab for the domain and etab name
    List<String> siren = List<String>.from(userInfo['ESCOSIRENCourant'] ?? []);
    Map<String, dynamic>? rawEtabInfo = await getInfoEtab(siren);
    if (rawEtabInfo == null) return UserInfoLoadingState.error;
    String currentSiren = siren[0];
    Map<String, dynamic> etabInfo = rawEtabInfo[currentSiren];
    // We can create the user infos with all the data gathered
    UserInfo().setCurrentEtabName(etabInfo["displayName"]);
    UserInfo().setCurrentSiren(currentSiren);
    UserInfo().setPicture(userInfo['picture'] ?? '');
    UserInfo().setName(userInfo['name']);
    UserInfo().setUid(userInfo['sub']);
    UserInfo().setSirens(userInfo['ESCOSIREN'].cast<String>());
    String domain = etabInfo["otherAttributes"]["ESCODomaines"][0];
    UserInfo().setDomain(domain);
    log.finest("Current domain is : $domain");
    log.finest("Registered domain in database is : ${Account().domain}");
    // If the domain in database is not the same as the domain from userinfos
    // It means it was changed => make a partial logout to refresh CAS attributes
    // TODO : only works if a new portal session was created -> clear portal session at startup ?
    if(domain != Account().domain){
      log.info("Domain has changed but not in app ! Making a partial logout to refresh CAS attributes");
      LoginService.instance.logout(Account().domain, true);
      Session().setPortalSessionCookie('');
      Session().persist();
      UserInfo().update();
      return UserInfoLoadingState.refresh;
    }
    // Update userinfo in database
    UserInfo().update();
    return UserInfoLoadingState.success;
  }

  /// uri parser for services who are based on cas auth
  String? serviceUriParser(String completeUri) {
    return Uri.parse(completeUri).queryParameters['service'];
  }
}
