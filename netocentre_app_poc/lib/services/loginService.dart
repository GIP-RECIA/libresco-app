import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:netocentre_app_poc/services/portalService.dart';
import 'package:netocentre_app_poc/singletons/baseUrl.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

class LoginService {

 // Dev only - allow self-signed ssl certificates
 http.Client ignoreSslClient() {
   var ioClient = HttpClient(context: SecurityContext(withTrustedRoots: false));
   ioClient.badCertificateCallback = ((cert, host, port) => true);

   return IOClient(ioClient);
 }

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

     print(cookiesList.length);
     print(cookiesList.toString());

     Iterable<String> jsessionidParser = cookiesList.where((str) => str.contains("JSESSIONID"));
     Iterable<String> idPortalParser = cookiesList.where((str) => str.contains("clusterIDPortail"));
     if(jsessionidParser.isNotEmpty){
       jsessionidCookie = jsessionidParser.first.substring(jsessionidParser.first.indexOf("=")+1);
       print("JSESSIONID COOKIE : $jsessionidCookie");
     }
     else{
       print("jsessionid not found");
     }
     if(idPortalParser.isNotEmpty){
       idPortalCookie = idPortalParser.first.substring(idPortalParser.first.indexOf("=")+1);
       print("idPortal COOKIE : $idPortalCookie");
     }
     else{
       print("idPortal not found");
     }
   }

   return (jsessionid: jsessionidCookie, idportal: idPortalCookie);
 }

 /// Used to check if the user has a CAS Session
 Future<bool> hasCASSession() async {
   final client = HttpClient();
   var uri = Uri.https(BaseUrl().casBaseURL, "/cas/login",);
   var request = await client.getUrl(uri);
   request.followRedirects = false;
   request.headers.add('Cookie', 'TGC=${TokenManager().TGT}');

   print(request.uri.toString());
   print("request headers : ${request.headers}");

   var response = await request.close();
   String body = await response.transform(utf8.decoder).join();

   print("Status code: ${response.statusCode}");
   print("Response headers: ${response.headers}");
   print("Body: $body");
   
   if(body.contains("view-genericsuccess-security")){
     print("USER CONNECTED TO CAS");
     return true;
   }

   print("USER NOT CONNECTED TO CAS");
   return false;
 }

 /// Used to earn the JSESSIONID
 Future<bool> unstackedUPortalLogin() async {

   // init variables
   int requestCounter = 0;
   String jsessionidCookie = "";
   String idPortalCookie = "";

   print("=== Start of unstacked uPortal login ===");

   /// Request 0 - initial request
   final client = HttpClient();
   var uri = Uri.https(
       BaseUrl().casBaseURL,
       "/cas/login",
       {
         'service': 'https://${BaseUrl().uPortalBaseURL}/portail/Login'
       }
   );
   var request = await client.getUrl(uri);
   request.followRedirects = false;
   request.headers.add('Cookie', 'TGC=${TokenManager().TGT}');

   print("\nRequest $requestCounter :");
   print(request.uri.toString());
   print("request headers : ${request.headers}");

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

       print("\nResponse $requestCounter :");
       print(response.statusCode);
       print("response headers : ${response.headers["set-cookie"]}");
       print("response location : $location");

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

       print("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
       print("\nRequest ${requestCounter + 1} :");
       print(request.uri.toString());
       print("request headers : ${request.headers}");

       requestCounter++;

       response = await request.close();
     }
   }

   /// Last response
   /// Parse last JSESSIONID & idPortal
   print("\nResponse $requestCounter :");
   print(response.statusCode);
   print("response headers : ${response.headers["set-cookie"]}");

   ({String jsessionid, String idportal}) parsingResult = uPortalLoginParser(response);
   if(parsingResult.jsessionid != "" ){
     jsessionidCookie = parsingResult.jsessionid;
   }
   if(parsingResult.idportal != "" ){
     idPortalCookie = parsingResult.idportal;
   }

   print("Final JSESSIONID : $jsessionidCookie");
   print("Final idPortal : $idPortalCookie");

   print("=== End of unstacked uPortal login ===");

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