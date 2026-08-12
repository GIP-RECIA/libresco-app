import 'dart:convert';
import 'dart:io';

import 'package:libresco/utils/sanitizer.dart';
import 'package:logging/logging.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';

import '../objects/singletons/session.dart';

/// Custom class used to store and retrieve cookies necessary when there are multiple redirects
class DnmaRequestCookieStore {

  final List<Cookie> _cookies = [];

  /// Save the cookies received from a given request (and updates them if necessary)
  void saveFromResponse(Uri uri, List<Cookie> newCookies) {
    for (final c in newCookies) {
      _cookies.removeWhere((old) => old.name == c.name && (old.domain ?? uri.host) == (c.domain ?? uri.host));
      c.domain ??= uri.host;
      c.path ??= "/";
      _cookies.add(c);
    }
  }

  /// Return all the cookies to send for a given uri
  List<Cookie> loadForRequest(Uri uri) {
    return _cookies.where((c) {
      final domain = c.domain ?? uri.host;
      final domainMatch = uri.host == domain || uri.host.endsWith(".$domain");
      final pathMatch = uri.path.startsWith(c.path ?? "/");
      final secureMatch = !c.secure || uri.scheme == "https";
      return domainMatch && pathMatch && secureMatch;
    }).toList();
  }

  /// Get value associated to cookie
  String getValue(String name) {
    for (final c in _cookies) {
      if (c.name == name) {
        return c.value;
      }
    }
    return "";
  }

}

class DnmaService {
  final log = Logger('DnmaService');

  DnmaService._privateConstructor();
  static final DnmaService _instance = DnmaService._privateConstructor();
  static DnmaService get instance => _instance;

  Cookie createCookie(String cookieName, String cookieValue, String domain, String path){
    Cookie cookie = Cookie(cookieName, cookieValue,);
    cookie.domain=AppConfig().casHost;
    cookie.path="/cas";
    cookie.secure = true;
    cookie.httpOnly = true;
    return cookie;
  }

  /// Send a mark request
  Future<int> sendMarkRequest(String dimension, String fname, String url) async {
    final client = HttpClient();
    client.userAgent = AppConfig().userAgent;
    final Uri uri = Uri.parse("https://${Account().domain}/dnma/api/v1/marquage");
    log.info("Sending mark request to $uri");
    final request = await client.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=utf-8",);
    request.headers.set(HttpHeaders.acceptHeader, "application/json",);
    // Add DNMA cookies to request
    final cookieDnmaSession = createCookie(AppConfig().cookieDNMASessionName,
        Session().DNMASessionCookie, Account().domain, "/dnma");
    final cookieDnmaId = createCookie(AppConfig().cookieDNMAIDName,
        Session().IDDNMACookie, Account().domain, "/dnma");
    final toSend = [cookieDnmaSession, cookieDnmaId];
    request.cookies.addAll(toSend);
    log.finer("Cookies sent are :");
    for (final c in toSend) {
      log.finer("   ${c.name}=${sanitize(c.value, visibleCharacters: 3)}");
    }
    // Add body
    final body = {"date":(DateTime.now().millisecondsSinceEpoch/1000).toInt().toString(), "dimension11":dimension,"fname":fname,"url":url};
    log.fine("Body to send is $body");
    final jsonBody = jsonEncode(body);
    final bytes = utf8.encode(jsonBody);
    request.headers.set(HttpHeaders.contentLengthHeader, bytes.length.toString(),);
    request.add(bytes);
    // Send request
    final response = await request.close();
    log.fine("Status: ${response.statusCode}");
    return response.statusCode;
  }

  /// Make a new DNMA mark (request + login if necessary)
  Future<void> mark(String dimension, String fname, String url) async {
    // If we have no DNMA cookie, we are sure we need to login
    bool loggedIn = false;
    if(Session().DNMASessionCookie == ""){
      loggedIn = await ensureLogin();
    } else {
      loggedIn = true;
    }
    // If login is successful or if we already have a cookie, send mark request
    if(loggedIn){
      if(await sendMarkRequest(dimension, fname, url) >= 400){
        log.info("DNMA request failed. Trying to obtain a new session...");
        if(await ensureLogin()){
          log.info("New session obtained, sending mark request again");
          if(await sendMarkRequest(dimension, fname, url) >= 400){
            log.warning("DNMA request failed !");
          } else {
            log.info("DNMA mark successfully sent");
          }
        } else {
          log.warning("DNMA request and login failed !");
        }
      } else {
        log.info("DNMA mark successfully sent");
      }
    // If login failed we know we will not be able to send request, so abort
    } else {
      log.warning("Can't login to DNMA, request was not sent");
    }

  }

  /// Create a DNMA session if necessary
  Future<bool> ensureLogin() async {
    if(Session().DNMASessionCookie == ""){
      log.info('Logging in to DNMA');

      final client = HttpClient();
      client.userAgent = AppConfig().userAgent;
      final cookies = DnmaRequestCookieStore();

      // Create and store TGC cookie for subsequent requests
      final tgc = createCookie(AppConfig().casCookieName, Session().CASSessionCookie, AppConfig().casHost, "/cas");
      Uri current = Uri.parse('https://${Account().domain}/dnma/api/v1/auth');
      cookies.saveFromResponse(current, [tgc]);

      bool done = false;
      int nbRequests = 1;

      // Follow redirects by hand to handle cookies correctly
      try {
        while (!done && nbRequests < 10) {
          log.fine("Request number $nbRequests : $current");

          // Create current request
          final request = await client.getUrl(current);
          request.followRedirects = false;

          // Add cookies to request
          final toSend = cookies.loadForRequest(current);
          log.fine("Cookies sent :");
          for (final c in toSend) {
            log.fine("   ${c.name}=${sanitize(c.value, visibleCharacters: 3)}");
          }
          request.cookies.addAll(toSend);

          // Send request and read response
          final response = await request.close();
          log.fine("Status: ${response.statusCode}");

          // Save received cookies
          cookies.saveFromResponse(current, response.cookies);
          log.fine("New cookies added :");
          for (final c in response.cookies) {
            log.fine("   ${c.name}=${sanitize(c.value, visibleCharacters: 3)}");
          }

          // Handle redirect in response
          if (response.isRedirect) {
            final loc = response.headers.value(HttpHeaders.locationHeader);
            if (loc == null) {
              log.warning("Invalid redirect");
              return false;
            }
            current = current.resolve(loc);
            log.fine("Redirect to $current");
            // If we are not redirected that means authentification is done
          } else {
            done = true;
            // Set session cookies
            Session().setDNMASessionCookie(cookies.getValue(AppConfig().cookieDNMASessionName));
            Session().setIDDNMACookie(cookies.getValue(AppConfig().cookieDNMAIDName));
            log.info("Session after DNMA login : ${Session().toString()}");
          }
          nbRequests++;
        }

        return done;
      } finally {
        client.close();
      }

    } else {
      return true;
    }
  }

}
