import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/singletons/app_config.dart';
import 'package:netocentre_app_poc/singletons/session.dart';

class LoginService {
  final log = Logger('LoginService');

  LoginService._privateConstructor();

  static final LoginService _instance = LoginService._privateConstructor();

  static LoginService get instance => _instance;

  Future<bool> isAuthorizedByUPortal() async {
    log.fine('Checking ${AppConfig().portalCookieName} validity...');
    if (!await hasPortalSession()) {
      return await instance.unstackedUPortalLogin();
    }
    return true;
  }

  Future<bool> hasPortalSession() async {
    // If user don't have any PortalSessionCookie it is not necessary to make a
    // request, we know we don't have a session
    if (Session().PortalSessionCookie == '') {
      log.finer('No ${AppConfig().portalCookieName} in Session');
      return false;
    }

    final client = IOClient(HttpClient());
    Uri request = Uri.https(
      AppConfig().uPortalHost,
      '/portail/api/session.json',
    );

    log.finer('Making a request to portal : $request');
    log.finer(
        '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}');

    final http.Response res = await client.get(
      request,
      headers: <String, String>{
        'Cookie':
            '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}; '
                '${AppConfig().portalIDCookieName}=${Session().IDPortalCookie}',
        'Host': AppConfig().uPortalHost
      },
    );

    log.finest('Status code : ${res.statusCode}');
    log.finest('Body : ${res.body}');
    // If we get a 200 we still need to check if the session is not a guest
    // session
    if (res.statusCode == 200) {
      if (json.decode(res.body)['person']['sessionKey'] != null) {
        log.fine('Portal session is valid !');
        return true;
      }
      log.fine('Portal session is guest -> Invalid');
      return false;
    }
    // If we have an invalid session this API will return a 404
    else {
      log.fine('Portal session is invalid');
      return false;
    }
  }

  /// Parser - portalSessionCookie & IDPortalCookie
  ({String session, String idportal}) uPortalLoginParser(
      HttpClientResponse response) {
    String portalSessionCookie = '';
    String idPortalCookie = '';

    if (response.headers['set-cookie']!.isNotEmpty) {
      List<String> rawCookiesList = response.headers['set-cookie']!;
      List<String> cookiesList = [];
      for (var rawCookies in rawCookiesList) {
        cookiesList.addAll(rawCookies.split(';'));
      }

      log.finer('List of cookies in portal response ${cookiesList.toString()}');

      Iterable<String> portalSessionCookieParser = cookiesList.where(
        (str) => str.startsWith(AppConfig().portalCookieName),
      );
      Iterable<String> idPortalCookieParser = cookiesList.where(
        (str) => str.startsWith(AppConfig().portalIDCookieName),
      );
      if (portalSessionCookieParser.isNotEmpty) {
        portalSessionCookie = portalSessionCookieParser.first
            .substring(portalSessionCookieParser.first.indexOf('=') + 1);
        log.finer(
          '${AppConfig().portalCookieName} cookie exists : '
          '$portalSessionCookie',
        );
      } else {
        log.finer('${AppConfig().portalCookieName} cookie not found');
      }
      if (idPortalCookieParser.isNotEmpty) {
        idPortalCookie = idPortalCookieParser.first
            .substring(idPortalCookieParser.first.indexOf('=') + 1);
        log.finer('idPortal cookie exists : $idPortalCookie');
      } else {
        log.finer('idPortal cookie not found');
      }
    }

    return (session: portalSessionCookie, idportal: idPortalCookie);
  }

  /// Used to check if the user has a CAS Session
  Future<bool> hasCASSession() async {
    log.fine('Checking if user is connected to CAS');
    final client = HttpClient();
    client.userAgent = AppConfig().userAgent;
    var uri = Uri.https(
      AppConfig().casHost,
      '/cas/login',
    );
    var request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.add(
      'Cookie',
      '${AppConfig().casCookieName}=${Session().CASSessionCookie}',
    );

    log.finer('Making this request to CAS server : ${request.uri.toString()}');
    log.finer('Request headers are : ${request.headers}');

    var response = await request.close();
    String body = await response.transform(utf8.decoder).join();

    log.finer('Response status code from cas server : ${response.statusCode}');
    log.finer('Response headers: ${response.headers}');
    log.finest('Body: $body');

    if (body.contains('view-genericsuccess-security')) {
      log.fine('User is connected to CAS');
      return true;
    }

    log.fine('User is not connected to CAS');
    return false;
  }

  Future<void> logout() async {
    final client = HttpClient();
    client.userAgent = AppConfig().userAgent;

    log.fine('Logging out the user from CAS');
    Uri casURI = Uri.https(AppConfig().casHost, '/cas/logout');
    log.finer('Making a request to CAS : $casURI');
    log.finer('${AppConfig().casCookieName}=${Session().CASSessionCookie}');

    var casRequest = await client.getUrl(casURI);
    casRequest.followRedirects = false;
    casRequest.headers.add(
      'Cookie',
      '${AppConfig().casCookieName}=${Session().CASSessionCookie}',
    );

    var casResponse = await casRequest.close();
    String casBody = await casResponse.transform(utf8.decoder).join();

    log.finer(
      'Response status code from cas server : ${casResponse.statusCode}',
    );
    log.finer('Response headers: ${casResponse.headers}');
    log.finest('Body: $casBody');

    log.fine('Logging out the user from Portal');
    Uri portalURI = Uri.https(AppConfig().uPortalHost, '/portail/Logout');

    log.finer('Making a request to portal : $portalURI');
    log.finer(
      '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}',
    );

    var portalRequest = await client.getUrl(portalURI);
    portalRequest.followRedirects = false;
    portalRequest.headers.add(
      'Cookie',
      '${AppConfig().portalCookieName}=${Session().PortalSessionCookie}; '
          '${AppConfig().portalIDCookieName}=${Session().IDPortalCookie}',
    );
    portalRequest.headers.add('Host', AppConfig().uPortalHost);

    var portalResponse = await portalRequest.close();
    log.finer(
      'Response status code from portal : ${portalResponse.statusCode}',
    );
    log.finer('Response headers: ${portalResponse.headers}');
  }

  /// Used to earn the portalSessionCookie
  Future<bool> unstackedUPortalLogin() async {
    // init variables
    int requestCounter = 0;
    String portalSessionCookie = '';
    String idPortalCookie = '';

    log.fine('=== Start of unstacked uPortal login ===');

    /// Request 0 - initial request
    final client = HttpClient();
    client.userAgent = AppConfig().userAgent;
    var uri = Uri.https(
      AppConfig().casHost,
      '/cas/login',
      {
        'service': '${AppConfig().uPortalBaseURL}/portail/Login',
      },
    );
    var request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.add(
      'Cookie',
      '${AppConfig().casCookieName}=${Session().CASSessionCookie}',
    );

    log.finer('\nRequest $requestCounter :');
    log.finer(request.uri.toString());
    log.finer('request headers : ${request.headers}');

    // Get the first response
    var response = await request.close();

    // While we get a redirect
    while (response.isRedirect && requestCounter < 10) {
      // redirect url
      final location = response.headers.value(HttpHeaders.locationHeader);

      if (location != null) {
        uri = uri.resolve(location);

        //Configure the new request
        request = await client.getUrl(uri.resolve(location));

        /// PARSE portalSessionCookie & idPortal

        log.finer('\nResponse $requestCounter :');
        log.finer(response.statusCode);
        log.finer('response headers : ${response.headers['set-cookie']}');
        log.finer('response location : $location');

        ({String session, String idportal}) parsingResult =
            uPortalLoginParser(response);
        if (parsingResult.session != '') {
          portalSessionCookie = parsingResult.session;
        }
        if (parsingResult.idportal != '') {
          idPortalCookie = parsingResult.idportal;
        }

        request.followRedirects = false;

        if (portalSessionCookie != '') {
          request.cookies.add(Cookie(
            AppConfig().portalCookieName,
            portalSessionCookie,
          ));
        }
        if (idPortalCookie != '') {
          request.cookies.add(Cookie(
            AppConfig().portalIDCookieName,
            idPortalCookie,
          ));
        }

        log.finer(
          '\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
          '=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-',
        );
        log.finer('\nRequest ${requestCounter + 1} :');
        log.finer(request.uri.toString());
        log.finer('request headers : ${request.headers}');

        requestCounter++;

        response = await request.close();
      }
    }

    /// Last response
    /// Parse last portalSessionCookie & idPortalCookie
    log.finer('\nResponse $requestCounter :');
    log.finer(response.statusCode);
    log.finer('response headers : ${response.headers['set-cookie']}');

    ({String session, String idportal}) parsingResult =
        uPortalLoginParser(response);
    if (parsingResult.session != '') {
      portalSessionCookie = parsingResult.session;
    }
    if (parsingResult.idportal != '') {
      idPortalCookie = parsingResult.idportal;
    }

    log.fine('Final ${AppConfig().portalCookieName} : $portalSessionCookie');
    log.fine('Final idPortal : $idPortalCookie');

    log.fine('=== End of unstacked uPortal login ===');

    if (portalSessionCookie != '') {
      Session().setIDportalCookie(idPortalCookie);
      Session().setPortalSessionCookie(portalSessionCookie);
      Session().persist();
      if (await hasPortalSession()) {
        return true;
      }
    }
    return false;
  }
}
