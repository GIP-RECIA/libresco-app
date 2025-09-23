import 'package:flutter/material.dart';
import 'package:netocentre_app_poc/pages/homePage.dart';
import 'package:netocentre_app_poc/pages/loadingPage.dart';
import 'package:netocentre_app_poc/pages/unconnectedHomePage.dart';
import 'package:netocentre_app_poc/repositories/tokenRepository.dart';
import 'package:netocentre_app_poc/services/portalService.dart';
import 'package:netocentre_app_poc/singletons/tokenManager.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("token manager before loaded : ${TokenManager().toString()}");
  await TokenRepository().getLastValidRefreshToken();
  // if we get a valid TGT from Database TODO: Need to verify if he's not expired
  if(TokenManager().TGT != ""){
    if(TokenManager().JSESSIONID == ""){
      await PortalService().isAuthorizedByUPortal(); // Generate a new JSESSIONID
    }
  }else{
    print("no valid TGT found");
  }
  print("token manager after loaded : ${TokenManager().toString()}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    if(TokenManager().TGT != "") { // TGT default value
      return const MaterialApp(
        title: 'Netocentre App POC',
        debugShowCheckedModeBanner: false,
        home: LoadingPage(callbackWidget: HomePage()),
      );
    }
    else{
      return const MaterialApp(
        title: 'Netocentre App POC',
        debugShowCheckedModeBanner: false,
        home: UnconnectedHomePage(),
      );
    }
  }
}
