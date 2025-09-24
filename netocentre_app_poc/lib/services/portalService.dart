import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:netocentre_app_poc/entities/service.dart';
import 'package:netocentre_app_poc/singletons/mediacentreFavorites.dart';
import 'package:netocentre_app_poc/singletons/servicesList.dart';
import 'package:netocentre_app_poc/singletons/userInfo.dart';
import 'package:netocentre_app_poc/services/loginService.dart';

import '../singletons/baseUrl.dart';
import '../singletons/tokenManager.dart';

class PortalService{


  http.Client ignoreSslClient() {
    var ioClient = HttpClient(context: SecurityContext(withTrustedRoots: false));
    ioClient.badCertificateCallback = ((cert, host, port) => true);

    return IOClient(ioClient);
  }

  Future<bool> isAuthorizedByUPortal() async{
    if(TokenManager().JSESSIONID != ""){
      return true;
    }
    else{
      print("JSESSIOND NOT FOUND - Request UPortal Login");
      return await LoginService().unstackedUPortalLogin();
    }
  }

  Future<void> getAllPortlets() async {
    print("getting portlets");

    final client = ignoreSslClient();

    Uri request = Uri.https(
        BaseUrl().uPortalBaseURL,
        "/portail/api/v4-3/dlm/portletRegistry.json",
        {'category': 'All categories'}
    );

    print("getting portlet request : $request");
    print("JSESSIONID=${TokenManager().JSESSIONID}");

    if(await isAuthorizedByUPortal()){
      final http.Response res = await client.get(
        request,
        headers: <String, String>{
          'Cookie': 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}',
          'Host': BaseUrl().uPortalBaseURL
        },
      );

      print(res.statusCode);
      if(res.statusCode == 200) {

        /// Parse json and get portlets fname

        final dynamic jsonSubcategories  = json.decode(res.body)["registry"]["categories"][0]["subcategories"];

        Set<String> portletsSet = {};

        List<Service> servicesList = [];
        List<Service> favoritesList = [];

        for(var subcategory in jsonSubcategories){
          for (var portlet in subcategory["portlets"]){
            if(!portletsSet.contains(portlet["fname"])){

              print("portlet ${portlet["title"]} favorite : ${portlet["favorite"]}");

              String portletIconUri = "";

              // get icon  uri
              if(portlet["parameters"].containsKey("mobileIconUrl")){
                portletIconUri = portlet["parameters"]["mobileIconUrl"]["value"];
                print("portlet ${portlet["title"]} icon url : $portletIconUri");

              }

              // if auth directly on CAS
              if(portlet["parameters"].containsKey("alternativeMaximizedLink")){
                String? serviceUri = serviceUriParser(portlet["parameters"]["alternativeMaximizedLink"]["value"]);
                if(serviceUri != null){
                  servicesList.add(
                      Service.CASBased(id: portlet["id"], text: portlet["title"], serviceUri: serviceUri, iconUri: portletIconUri, isFavorite: portlet["favorite"], fname: portlet["fname"])
                  );
                  if(portlet["favorite"]){
                    favoritesList.add(Service.CASBased(id: portlet["id"], text: portlet["title"], serviceUri: serviceUri, iconUri: portletIconUri, isFavorite: portlet["favorite"], fname: portlet["fname"]));
                  }
                }
                else {
                  print("service uri is null !");
                }
              }
              else{
                servicesList.add(
                    Service.UPortalBased(id: portlet["id"], text: portlet["title"], serviceUri: portlet["fname"], iconUri: portletIconUri, isFavorite: portlet["favorite"])
                );
                if(portlet["favorite"]){
                  favoritesList.add(Service.UPortalBased(id: portlet["id"], text: portlet["title"], serviceUri: portlet["fname"], iconUri: portletIconUri, isFavorite: portlet["favorite"]));
                }
              }
              print(portlet["fname"]);
              portletsSet = {...portletsSet, portlet["fname"]};
            }
          }

        }
        

        Services().setServicesList(servicesList);
        Services().setFavoritesList(favoritesList);


        final List<String> portlets = portletsSet.toList(growable: false);

        print(portlets.toString());
        print(Services().servicesList.length);

      }
      else{
        print("on a un problème là ! :'(");
      }
    }
    else{
      print("JSESSIONID Empty !");
    }
  }

  Future<bool> switchPortletIsFavoriteState(Service service) async {
    print("switching portlet is favorite state");

    // Switch "is favorite" attribute state
    bool ApiResponseResult = await requestSwitchPortletIsFavoriteState(service);

    if(ApiResponseResult) {

      List<Service> currentServicesList = Services().servicesList;
      List<Service> currentFavoritesList = Services().favoritesList;

      currentServicesList.removeWhere((indexedService) => indexedService.id == service.id);

      service.isFavorite = !(service.isFavorite);

      /// if it was in favorites list
      if(!(service.isFavorite)){
        // remove from favorites list
        currentFavoritesList.removeWhere((indexedService) => indexedService.id == service.id);
      }
      else{
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
    print("requesting API to switch portlet is favorite state");

    final client = ignoreSslClient();

    Uri request = Uri.https(
        BaseUrl().uPortalBaseURL,
        "/portail/api/layout",
        {
          'action': service.isFavorite ? 'removeFavorite': 'addFavorite',
          'channelId': service.id.toString()
        }
    );

    print("getting portlet request : $request");
    print("JSESSIONID=${TokenManager().JSESSIONID}");

    if(await isAuthorizedByUPortal()){
      final http.Response res = await client.post(
        request,
        headers: <String, String>{
          'Cookie': 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}',
          'Host': BaseUrl().uPortalBaseURL
        },
      );

      print(res.statusCode);
      if(res.statusCode == 200) {
        return true;
      }
      else{
        print("on a un problème là ! :'(");
      }
    }


    return false;
  }

  Future<Map<String, dynamic>> getUserInfo() async{
    print("getting user infos");

    final client = ignoreSslClient();

    Uri request = Uri.https(
        BaseUrl().uPortalBaseURL,
        "/portail/api/v5-1/userinfo",
        {
          'claims': 'private,picture,name,ESCOSIRENCourant,ESCOSIREN',
          'groups': ''
        }
    );

    print("getting portlet request : $request");
    print("JSESSIONID=${TokenManager().JSESSIONID}");

    if(await isAuthorizedByUPortal()){
      final http.Response res = await client.get(
        request,
        headers: <String, String>{
          'Cookie': 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}',
          'Host': BaseUrl().uPortalBaseURL
        },
      );

      print(res.statusCode);
      if(res.statusCode == 200) {

        /// Decode base64 and parse json
        print(res.body);

        String base64url = res.body.split('.')[1];
        base64url = base64url.replaceAll("-", "+").replaceAll("_", "/");

        if(base64url.length % 4 != 0){
          base64url = base64url + ("=" * (4-(base64url.length % 4)));
        }

        print(base64url);

        print(utf8.decode(base64.decode(base64url)));

        return json.decode(utf8.decode(base64.decode(base64url)));
      }
      else{
        print("on a un problème là ! :'(");
        return {};
      }
    }
    else{
      print("JSESSIONID Empty !");
      return {};
    }
  }

  Future<void> loadUserInfo() async {
    final dynamic rawUserInfo = await getUserInfo();

    print("USER INFO");
    print(rawUserInfo);
    
    if((rawUserInfo["sub"] as String).contains("guest-")){
      print("USER GUEST -> JSESSIONID EXPIRED : STARTING NEW LOGIN");
      await LoginService().unstackedUPortalLogin();
    }

    UserInfo().setFirstname((rawUserInfo["name"] as String).split(" ")[0]);
    //UserInfo().setLastname((rawUserInfo["name"] as String).split(" ")[1]);
  }

  // uri parser for services who are based on cas auth
  String? serviceUriParser(String completeUri) {
    print(completeUri);
    return Uri.parse(completeUri).queryParameters["service"];
  }

  /// MediaCentre - Main Function
  Future<void> mediacentreFavoritesWorkflow() async {

    List<String> ressourcesList = [];

    String bearer = await getUserInfoMediacentre();

    String groupsRegexData = await getGroupsRegexFromConfig(bearer);

    List<dynamic> groups = await getGroups(bearer);

    /// Filter groups with regex

    List<String> userGroups = [];

    RegExp groupsRegex = RegExp(
        r'^.*:(admin|Inter_etablissements|Etablissements|Applications):.*$', // TODO : à remplacer par groupsRegexData quand fonctionnel
        multiLine: true,
        caseSensitive: true
    );

    for (var group in groups) {
      Map<String, dynamic> currGroup = group;
      if(groupsRegex.hasMatch(currGroup["name"])){
        userGroups.add(currGroup["name"]);
      }
    }

    /// Get favorite ressources

    List<dynamic> ressources = await getRessources(bearer, userGroups);

    Map<String, dynamic> favRessourceIds = await getFavoriteRessourceIds(bearer);

    List<String> favRessources = List<String>.from(favRessourceIds["mediacentreFavorites"] as List);

    for(var ressource in ressources){
      Map<String, dynamic> currRessource = ressource;
      if(favRessources.contains(currRessource["idRessource"])) {
        print("fav : ${currRessource["nomRessource"]}");
        ressourcesList.add(currRessource["nomRessource"]);
      }
    }

    print("================================================\n======================== ${ressourcesList.length} ========================\n================================================");

    MediacentreFavorites().setFavorites(ressourcesList);

    //return ressourcesList;
  }

  /// MediaCentre
  Future<String> getUserInfoMediacentre() async{
    print("getting user infos - mediacentre");

    final client = ignoreSslClient();

    Uri request = Uri.https(
        BaseUrl().uPortalBaseURL,
        "/portail/api/v5-1/userinfo",
        {
          'claims': 'private,ESCOSIRENCourant,ESCOSIREN,ENTPersonGARIdentifiant,profile',
          'groups': ''
        }
    );

    print("getting portlet request : $request");
    print("JSESSIONID=${TokenManager().JSESSIONID}");

    if(await isAuthorizedByUPortal()){
      final http.Response res = await client.get(
        request,
        headers: <String, String>{
          'Cookie': 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}',
          'Host': BaseUrl().uPortalBaseURL
        },
      );

      print(res.statusCode);
      if(res.statusCode == 200) {
        return res.body;
      }
      else{
        print("on a un problème là ! :'(");
        return "";
      }
    }
    else{
      print("JSESSIONID Empty !");
      return "";
    }
  }

  /// MediaCentre
  Future<List<dynamic>> getGroups(String bearer) async{
    print("getting user infos");

    final client = ignoreSslClient();

    List<dynamic> data;

    Uri request = Uri.https(
        BaseUrl().uPortalBaseURL,
        "/portail/api/groups",
        {}
    );

    print("getting portlet request : $request");
    print("JSESSIONID=${TokenManager().JSESSIONID}");

    if(await isAuthorizedByUPortal()){
      final http.Response res = await client.get(
        request,
        headers: <String, String>{
          'Cookie': 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}',
          'Host': BaseUrl().uPortalBaseURL,
          'Authorization': 'Bearer $bearer'
        },
      );

      print(res.statusCode);
      if(res.statusCode == 200) {

        data = json.decode(res.body)["groups"];

        return data;
      }
      else{
        print("on a un problème là ! :'(");

        data = [];

        return data;
      }
    }
    else{
      print("JSESSIONID Empty !");

      data = [];

      return data;
    }
  }

  /// MediaCentre
  Future<String> getGroupsRegexFromConfig(String bearer) async{
    print("getting user infos");

    final client = ignoreSslClient();

    Uri request = Uri.https(
        BaseUrl().uPortalBaseURL,
        "/mediacentre-api/api/config",
        {}
    );

    print("getting portlet request : $request");
    print("JSESSIONID=${TokenManager().JSESSIONID}");

    if(await isAuthorizedByUPortal()){
      final http.Response res = await client.get(
        request,
        headers: <String, String>{
          'Cookie': 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}',
          'Host': BaseUrl().uPortalBaseURL,
          'Authorization': 'Bearer $bearer'
        },
      );

      print(res.statusCode);
      if(res.statusCode == 200) {

        List<dynamic> credentials = json.decode(res.body);

        String regex = credentials[0]["value"];

        return regex;
      }
      else{
        print("on a un problème là ! :'(");
        return "";
      }
    }
    else{
      print("JSESSIONID Empty !");
      return "";
    }
  }

  /// MediaCentre
  Future<List<dynamic>> getRessources(String bearer, List<String> userGroups) async{
    print("getting user infos");

    final client = ignoreSslClient();

    Uri request = Uri.https(
        BaseUrl().uPortalBaseURL,
        "/mediacentre-api/api/resources",
        {}
    );

    print("getting portlet request : $request");
    print("JSESSIONID=${TokenManager().JSESSIONID}");

    Map<String,dynamic> bodyMap = {
      'isMemberOf': userGroups
    };

    if(await isAuthorizedByUPortal()){
      final http.Response res = await client.post(
          request,
          headers: <String, String>{
            'Cookie': 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}',
            'Host': BaseUrl().uPortalBaseURL,
            'Authorization': 'Bearer $bearer',
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/plain, */*'
          },
          body: jsonEncode(bodyMap)
      );

      print(res.statusCode);
      if(res.statusCode == 200) {

        print(res.body);

        List<dynamic> ressources = json.decode(res.body);

        return ressources;
      }
      else{
        print("on a un problème là ! :'(");
        return [];
      }
    }
    else{
      print("JSESSIONID Empty !");
      return [];
    }
  }

  /// MediaCentre
  Future<Map<String,dynamic>> getFavoriteRessourceIds(String bearer) async{
    print("getting user infos");

    final client = ignoreSslClient();

    Uri request = Uri.https(
        BaseUrl().uPortalBaseURL,
        "/portail/api/prefs/getentityonlyprefs/Mediacentre",
        {}
    );

    print("getting portlet request : $request");
    print("JSESSIONID=${TokenManager().JSESSIONID}");

    if(await isAuthorizedByUPortal()){
      final http.Response res = await client.get(
          request,
          headers: <String, String>{
            'Cookie': 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}',
            'Host': BaseUrl().uPortalBaseURL,
            'Authorization': 'Bearer $bearer',
            'Content-Type': 'application/json'
          }
      );

      print(res.statusCode);
      if(res.statusCode == 200) {

        print(json.decode(res.body));

        Map<String,dynamic> ressources = json.decode(res.body);

        return ressources;
      }
      else{
        print("on a un problème là ! :'(");
        return {};
      }
    }
    else{
      print("JSESSIONID Empty !");
      return {};
    }
  }
}