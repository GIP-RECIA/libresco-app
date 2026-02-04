import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/objects/singletons/account.dart';
import 'package:netocentre_app_poc/objects/singletons/app_config.dart';
import 'package:netocentre_app_poc/objects/singletons/session.dart';
import 'package:netocentre_app_poc/objects/singletons/user_info.dart';

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

    final String domain = Account().domain;
    log.finer('Domain for the user is $domain');

    final client = IOClient(HttpClient());
    Uri request = Uri.https(
      domain,
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
        'Host': domain
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
    final String domain = Account().domain;
    log.finer('Domain for the user is $domain');
    Uri portalURI = Uri.https(domain, '/portail/Logout');

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
    portalRequest.headers.add('Host', domain);

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
        'service': '${Account().getBaseUrl()}/portail/Login',
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

        // If the URI starts with CAS in the first redirect, that means there was a domain change
        // So we remember the domain for the rest of the requests. Once we will obtain userinfos
        // it will not be necessary anymore
        if(requestCounter == 0 && uri.toString().startsWith(AppConfig().casBaseURL)){
          log.fine('Multidomain redirection detected on URL : ${uri.toString()}');
          String service = (uri.toString().split("service=")[1]).split("/portail/Login")[0];
          AppConfig().setUportalBaseURL(service);
          log.fine('Base URL for next requests is set to $service');
        }

        //Configure the new request
        request = await client.getUrl(uri.resolve(location));
        if(uri.toString().contains("https://auth.recia.fr/cas/login")){
          request.headers.add(
            'Cookie',
            '${AppConfig().casCookieName}=${Session().CASSessionCookie}',
          );
        }

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
