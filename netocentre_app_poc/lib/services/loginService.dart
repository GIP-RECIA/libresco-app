import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/services/portalService.dart';
import 'package:netocentre_app_poc/singletons/appConfig.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

class LoginService {

  final log = Logger('LoginService');

 /// Parser - JSESSIONID & idPortal
 ({String jsessionid, String idportal}) uPortalLoginParser(HttpClientResponse response){

   String jsessionidCookie = "";
   String idPortalCookie = "";

   if(response.headers["set-cookie"]!.isNotEmpty){

     List<String> rawCookiesList = response.headers["set-cookie"]!;
     List<String> cookiesList = [];
     for (var rawCookies in rawCookiesList){
       cookiesList.addAll(rawCookies.split(";"));
     }

     log.finer('List of cookies in portal response ${cookiesList.toString()}');

     Iterable<String> jsessionidParser = cookiesList.where((str) => str.contains("JSESSIONID"));
     Iterable<String> idPortalParser = cookiesList.where((str) => str.contains("clusterIDPortail"));
     if(jsessionidParser.isNotEmpty){
       jsessionidCookie = jsessionidParser.first.substring(jsessionidParser.first.indexOf("=")+1);
       log.finer("JSESSIONID cookie exists : $jsessionidCookie");
     }
     else{
       log.finer("JSESSIONID cookie not found");
     }
     if(idPortalParser.isNotEmpty){
       idPortalCookie = idPortalParser.first.substring(idPortalParser.first.indexOf("=")+1);
       log.finer("idPortal cookie exists : $idPortalCookie");
     }
     else{
       log.finer("idPortal cookie not found");
     }
   }

   return (jsessionid: jsessionidCookie, idportal: idPortalCookie);
 }

 /// Used to check if the user has a CAS Session
 Future<bool> hasCASSession() async {
   log.fine("Checking if user is connected to CAS");
   final client = HttpClient();
   client.userAgent = AppConfig().userAgent;
   var uri = Uri.https(AppConfig().casBaseURL, "/cas/login",);
   var request = await client.getUrl(uri);
   request.followRedirects = false;
   request.headers.add('Cookie', 'TGC=${TokenManager().TGT}');

   log.finer('Making this request to CAS server : ${request.uri.toString()}');
   log.finer("Request headers are : ${request.headers}");

   var response = await request.close();
   String body = await response.transform(utf8.decoder).join();

   log.finer("Response status code from cas server : ${response.statusCode}");
   log.finer("Response headers: ${response.headers}");
   log.finest("Body: $body");
   
   if(body.contains("view-genericsuccess-security")){
     log.fine("User is connected to CAS");
     return true;
   }

   log.fine("User is not connected to CAS");
   return false;
 }

 Future<void> logout() async {
   final client = HttpClient();
   client.userAgent = AppConfig().userAgent;

   log.fine("Logging out the user from CAS");
   Uri casURI = Uri.https(AppConfig().casBaseURL, "/cas/logout");
   log.finer("Making a request to CAS : $casURI");
   log.finer("TGT=${TokenManager().TGT}");

   var casRequest = await client.getUrl(casURI);
   casRequest.followRedirects = false;
   casRequest.headers.add('Cookie', 'TGC=${TokenManager().TGT}');

   var casResponse = await casRequest.close();
   String casBody = await casResponse.transform(utf8.decoder).join();

   log.finer("Response status code from cas server : ${casResponse.statusCode}");
   log.finer("Response headers: ${casResponse.headers}");
   log.finest("Body: $casBody");

   log.fine("Logging out the user from Portal");
   Uri portalURI = Uri.https(AppConfig().uPortalBaseURL, "/portail/Logout");

   log.finer("Making a request to portal : $portalURI");
   log.finer("JSESSIONID=${TokenManager().JSESSIONID}");

   var portalRequest = await client.getUrl(portalURI);
   portalRequest.followRedirects = false;
   portalRequest.headers.add('Cookie', 'JSESSIONID=${TokenManager().JSESSIONID}; clusterIDPortail=${TokenManager().idPortal}');
   portalRequest.headers.add('Host', AppConfig().uPortalBaseURL);

   var portalResponse = await portalRequest.close();
   log.finer("Response status code from portal : ${portalResponse.statusCode}");
   log.finer("Response headers: ${portalResponse.headers}");
 }

 /// Used to earn the JSESSIONID
 Future<bool> unstackedUPortalLogin() async {

   // init variables
   int requestCounter = 0;
   String jsessionidCookie = "";
   String idPortalCookie = "";

   log.fine("=== Start of unstacked uPortal login ===");

   /// Request 0 - initial request
   final client = HttpClient();
   client.userAgent = AppConfig().userAgent;
   var uri = Uri.https(
       AppConfig().casBaseURL,
       "/cas/login",
       {
         'service': 'https://${AppConfig().uPortalBaseURL}/portail/Login'
       }
   );
   var request = await client.getUrl(uri);
   request.followRedirects = false;
   request.headers.add('Cookie', 'TGC=${TokenManager().TGT}');

   log.finer("\nRequest $requestCounter :");
   log.finer(request.uri.toString());
   log.finer("request headers : ${request.headers}");

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

       /// PARSE JSESSIONID & idPortal

       log.finer("\nResponse $requestCounter :");
       log.finer(response.statusCode);
       log.finer("response headers : ${response.headers["set-cookie"]}");
       log.finer("response location : $location");

       ({String jsessionid, String idportal}) parsingResult = uPortalLoginParser(response);
       if(parsingResult.jsessionid != "" ){
         jsessionidCookie = parsingResult.jsessionid;
       }
       if(parsingResult.idportal != "" ){
         idPortalCookie = parsingResult.idportal;
       }

       request.followRedirects = false;

       if(jsessionidCookie != ""){
         request.cookies.add(Cookie("JSESSIONID", jsessionidCookie));
       }
       if(idPortalCookie != ""){
         request.cookies.add(Cookie("clusterIDPortail", idPortalCookie));
       }

       log.finer("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
       log.finer("\nRequest ${requestCounter + 1} :");
       log.finer(request.uri.toString());
       log.finer("request headers : ${request.headers}");

       requestCounter++;

       response = await request.close();
     }
   }

   /// Last response
   /// Parse last JSESSIONID & idPortal
   log.finer("\nResponse $requestCounter :");
   log.finer(response.statusCode);
   log.finer("response headers : ${response.headers["set-cookie"]}");

   ({String jsessionid, String idportal}) parsingResult = uPortalLoginParser(response);
   if(parsingResult.jsessionid != "" ){
     jsessionidCookie = parsingResult.jsessionid;
   }
   if(parsingResult.idportal != "" ){
     idPortalCookie = parsingResult.idportal;
   }

   log.fine("Final JSESSIONID : $jsessionidCookie");
   log.fine("Final idPortal : $idPortalCookie");

   log.fine("=== End of unstacked uPortal login ===");

   if(idPortalCookie != "" && jsessionidCookie != ""){
     TokenManager().setIdPortal(idPortalCookie, flush: true);
     TokenManager().setJSESSIONID(jsessionidCookie, flush: true);
     if(await PortalService().hasPortalSession()){
        return true;
     }
   }
   return false;
 }
}