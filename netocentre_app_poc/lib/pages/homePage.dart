import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:netocentre_app_poc/entities/service.dart';
import 'package:netocentre_app_poc/pages/components/myAppBar.dart';
import 'package:netocentre_app_poc/pages/loadingPage.dart';
import 'package:netocentre_app_poc/singletons/userInfo.dart';

import '../singletons/appConfig.dart';
import '../singletons/servicesList.dart';
import '../singletons/tokenManager.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{

  static const String title = 'Une actualité concernant des évènements actuels';
  static const String type = 'Établissement';
  static const String desc = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
  final log = Logger('HomePageState');

  List<Service> renderedServices = Services().servicesList;
  List<Service> renderedFavoriteServices = Services().favoritesList;

  @override
  void initState() {
    super.initState();

    if(UserInfo().firstname == ""){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoadingPage(callbackWidget: HomePage())));
    }

    CookieManager manager = CookieManager.instance();
    manager.removeSessionCookies();

    manager.setCookie(
      url: WebUri("https://${AppConfig().uPortalBaseURL}/"),
      name: "JSESSIONID",
      value: TokenManager().JSESSIONID,
      isHttpOnly: true,
      isSecure: true,
      sameSite: HTTPCookieSameSitePolicy.NONE,
      domain: AppConfig().uPortalBaseURL,
      path: "/",
    );

    manager.setCookie(
      url: WebUri("https://${AppConfig().uPortalBaseURL}/"),
      name: "clusterIDPortail",
      value: TokenManager().idPortal,
      isHttpOnly: true,
      isSecure: true,
      sameSite: HTTPCookieSameSitePolicy.NONE,
      domain: AppConfig().uPortalBaseURL,
      path: "/",
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldwithIntegratedSearchBar(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  "Bienvenue sur votre ENT, ${UserInfo().firstname}",
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 900, // hauteur fixe dans ta page
              child: InAppWebView(
                // charge du HTML inline
                initialData: InAppWebViewInitialData(
                  data: """
        <html>
          <head>
            <style>@font-face{font-family:"DM Sans";src:url("/commun/fonts/DM_Sans/static/DMSans-Bold.ttf") format("truetype");font-weight:bold;font-style:normal;font-display:swap}@font-face{font-family:"DM Sans";src:url("/commun/fonts/DM_Sans/static/DMSans-BoldItalic.ttf") format("truetype");font-weight:bold;font-style:italic;font-display:swap}@font-face{font-family:"DM Sans";src:url("/commun/fonts/DM_Sans/static/DMSans-Italic.ttf") format("truetype");font-weight:normal;font-style:italic;font-display:swap}@font-face{font-family:"DM Sans";src:url("/commun/fonts/DM_Sans/static/DMSans-Medium.ttf") format("truetype");font-weight:500;font-style:normal;font-display:swap}@font-face{font-family:"DM Sans";src:url("/commun/fonts/DM_Sans/static/DMSans-MediumItalic.ttf") format("truetype");font-weight:500;font-style:italic;font-display:swap}@font-face{font-family:"DM Sans";src:url("/commun/fonts/DM_Sans/static/DMSans-Regular.ttf") format("truetype");font-weight:normal;font-style:normal;font-display:swap}@font-face{font-family:"DM Sans";src:url("/commun/fonts/DM_Sans/static/DMSans-SemiBold.ttf") format("truetype");font-weight:600;font-style:normal;font-display:swap}@font-face{font-family:"Sora";src:url("/commun/fonts/Sora/static/Sora-Bold.ttf") format("truetype");font-weight:bold;font-style:normal;font-display:swap}@font-face{font-family:"Sora";src:url("/commun/fonts/Sora/static/Sora-Regular.ttf") format("truetype");font-weight:normal;font-style:normal;font-display:swap}@font-face{font-family:"Sora";src:url("/commun/fonts/Sora/static/Sora-SemiBold.ttf") format("truetype");font-weight:600;font-style:normal;font-display:swap}html.services-layout,html.search-results{overflow-y:hidden}body.auto-margin-top{margin-top:var(--recia-header-height)}body.transition-active{transition:margin-left .15s cubic-bezier(0.4, 0, 0.2, 1)}@media(width >= 768px){body.navigation-drawer-visible{margin-left:var(--recia-drawer-width)}}:root{--recia-body: #1E1E1E;--recia-body-inverted: #FFF;--recia-body-bg: #FFF;--recia-favorite: #FFAA46;--recia-stroke: #E9E9E9;--recia-tutorial: #171717;--recia-basic-grey: #F4F4F4;--recia-basic-black: #1E1E1E;--recia-basic-black-lighter: #737373;--recia-lighter-black: #2C2C2C;--recia-system-blue: #005099;--recia-system-red: #AD1919;--recia-primary: #0062BC;--recia-primary-light: #0062BC;--recia-hover: #F8F8F8;--recia-hover-light: #F8F8F8;--recia-primary-inverted: #57AEFF;--recia-primary-dark: #57AEFF;--recia-hover-inverted: #262626;--recia-hover-dark: #262626;--recia-default: #858585;--recia-default-hover: #5B5B5B;--recia-default-hover-shadow: rgba(from #161616 r g b/0.15);--recia-default-text: #000;--recia-administrationSupport: #EC407A;--recia-administrationSupport-hover: #F60086;--recia-administrationSupport-hover-shadow: rgba(from #EC407A r g b/0.2);--recia-administrationSupport-text: #000;--recia-rhGestion: #AB47BC;--recia-rhGestion-hover: #C400F3;--recia-rhGestion-hover-shadow: rgba(from #C400F3 r g b/0.1);--recia-rhGestion-text: #FFF;--recia-communicationCollaboration: #5747BC;--recia-communicationCollaboration-hover: #665BE7;--recia-communicationCollaboration-hover-shadow: rgba(from #665BE7 r g b/0.15);--recia-communicationCollaboration-text: #FFF;--recia-apprentissageSuivi: #FFAC2F;--recia-apprentissageSuivi-hover: #F5C72E;--recia-apprentissageSuivi-hover-shadow: rgba(from #9D7A06 r g b/0.15);--recia-apprentissageSuivi-text: #000;--recia-citoyensTerritoriaux: #26C6DA;--recia-citoyensTerritoriaux-hover: #70EAF5;--recia-citoyensTerritoriaux-hover-shadow: rgba(from #06829D r g b/0.15);--recia-citoyensTerritoriaux-text: #000;--recia-documentsRessources: #66BB6A;--recia-documentsRessources-hover: #4EF186;--recia-documentsRessources-hover-shadow: rgba(from #069D28 r g b/0.15);--recia-documentsRessources-text: #000;--recia-btn-primary: #FFF;--recia-btn-primary-light: #FFF;--recia-btn-primary-pressed: #004584;--recia-btn-primary-pressed-light: #004584;--recia-btn-secondary: #1E1E1E;--recia-btn-secondary-light: #1E1E1E;--recia-btn-secondary-hover: #E6EFF8;--recia-btn-secondary-hover-light: #E6EFF8;--recia-btn-secondary-pressed: #CCE0F2;--recia-btn-secondary-pressed-light: #CCE0F2;--recia-btn-primary-bg: #1E1E1E;--recia-btn-primary-bg-light: #1E1E1E;--recia-btn-secondary-bg: #F4F4F4;--recia-btn-secondary-bg-light: #F4F4F4;--recia-btn-primary-inverted: #1E1E1E;--recia-btn-primary-dark: #1E1E1E;--recia-btn-primary-pressed-inverted: #8AC7FF;--recia-btn-primary-pressed-dark: #8AC7FF;--recia-btn-secondary-inverted: #FFF;--recia-btn-secondary-dark: #FFF;--recia-btn-secondary-hover-inverted: #1A1F23;--recia-btn-secondary-hover-dark: #1A1F23;--recia-btn-secondary-pressed-inverted: #212E3A;--recia-btn-secondary-pressed-dark: #212E3A;--recia-btn-primary-bg-inverted: #FFF;--recia-btn-primary-bg-dark: #FFF;--recia-btn-secondary-bg-inverted: #1E1E1E;--recia-btn-secondary-bg-dark: #1E1E1E;--recia-shadow-neutral: 0 4px 15.9px 0;--recia-shadow-strong: 0 4px 24.4px 0;--recia-shadow-hover: 0 4px 26px 0;--recia-shadow-low-elevation: 0 2px 6px 0;--recia-shadow-low-elevation-avatar-notif: 0 1px 24px 0;--recia-font-size-base: 1rem;--recia-body-font-size: calc(var(--recia-font-size-base) * 0.75);--recia-font-size-xxs: calc(var(--recia-font-size-base) * 0.625);--recia-font-size-xs: calc(var(--recia-font-size-base) * 0.75);--recia-font-size-sm: calc(var(--recia-font-size-base) * 0.875);--recia-font-size-md: calc(var(--recia-font-size-base) * 1);--recia-font-size-lg: calc(var(--recia-font-size-base) * 1.125);--recia-font-size-xl: calc(var(--recia-font-size-base) * 1.25);--recia-font-size-xxl: calc(var(--recia-font-size-base) * 1.5);--recia-font-size-h1: calc(var(--recia-font-size-base) * 1.25);--recia-font-size-h2: calc(var(--recia-font-size-base) * 1.125);--recia-font-size-h3: calc(var(--recia-font-size-base) * 1);--recia-font-size-h4: calc(var(--recia-font-size-base) * 0.875);--recia-drawer-width: 72px;--recia-header-height: 68px}@media screen and (width >= 992px){:root{--recia-body-font-size: calc(var(--recia-font-size-base) * 0.875);--recia-font-size-h1: calc(var(--recia-font-size-base) * 1.5);--recia-font-size-h2: calc(var(--recia-font-size-base) * 1.25);--recia-font-size-h3: calc(var(--recia-font-size-base) * 1);--recia-font-size-h4: calc(var(--recia-font-size-base) * 0.875)}}.theme-agri{--recia-primary: #37872A;--recia-primary-light: #37872A;--recia-primary-inverted: #87B77F;--recia-primary-dark: #87B77F;--recia-btn-primary-pressed: #275F1D;--recia-btn-primary-pressed-light: #275F1D;--recia-btn-secondary-hover: #EBF3EA;--recia-btn-secondary-hover-light: #EBF3EA;--recia-btn-secondary-pressed: #D7E7D4;--recia-btn-secondary-pressed-light: #D7E7D4;--recia-btn-primary-pressed-inverted: #AFCFAA;--recia-btn-primary-pressed-dark: #AFCFAA;--recia-btn-secondary-hover-inverted: #1D1F1C;--recia-btn-secondary-hover-dark: #1D1F1C;--recia-btn-secondary-pressed-inverted: #282F27;--recia-btn-secondary-pressed-dark: #282F27}.theme-chercan{--recia-primary: #004899;--recia-primary-light: #004899;--recia-primary-inverted: #6691C2;--recia-primary-dark: #6691C2;--recia-btn-primary-pressed: #00326B;--recia-btn-primary-pressed-light: #00326B;--recia-btn-secondary-hover: #E6EDF5;--recia-btn-secondary-hover-light: #E6EDF5;--recia-btn-secondary-pressed: #CCDAEB;--recia-btn-secondary-pressed-light: #CCDAEB;--recia-btn-primary-pressed-inverted: #99B6D6;--recia-btn-primary-pressed-dark: #99B6D6;--recia-btn-secondary-hover-inverted: #1B1D20;--recia-btn-secondary-hover-dark: #1B1D20;--recia-btn-secondary-pressed-inverted: #232A31;--recia-btn-secondary-pressed-dark: #232A31}.theme-colleges-eureliens{--recia-primary: #AE9E22;--recia-primary-light: #AE9E22;--recia-primary-inverted: #AE9E22;--recia-primary-dark: #AE9E22;--recia-btn-primary-pressed: #8C7F1A;--recia-btn-primary-pressed-light: #8C7F1A;--recia-btn-secondary-hover: #F5F3E6;--recia-btn-secondary-hover-light: #F5F3E6;--recia-btn-secondary-pressed: #EBE8CC;--recia-btn-secondary-pressed-light: #EBE8CC;--recia-btn-primary-pressed-inverted: #8C7F1A;--recia-btn-primary-pressed-dark: #8C7F1A;--recia-btn-secondary-hover-inverted: #1F1F1C;--recia-btn-secondary-hover-dark: #1F1F1C;--recia-btn-secondary-pressed-inverted: #2F2E27;--recia-btn-secondary-pressed-dark: #2F2E27}.theme-colleges-indre{--recia-primary: #004899;--recia-primary-light: #004899;--recia-primary-inverted: #6691C2;--recia-primary-dark: #6691C2;--recia-btn-primary-pressed: #00326B;--recia-btn-primary-pressed-light: #00326B;--recia-btn-secondary-hover: #E6EDF5;--recia-btn-secondary-hover-light: #E6EDF5;--recia-btn-secondary-pressed: #CCDAEB;--recia-btn-secondary-pressed-light: #CCDAEB;--recia-btn-primary-pressed-inverted: #99B6D6;--recia-btn-primary-pressed-dark: #99B6D6;--recia-btn-secondary-hover-inverted: #1B1D20;--recia-btn-secondary-hover-dark: #1B1D20;--recia-btn-secondary-pressed-inverted: #232A31;--recia-btn-secondary-pressed-dark: #232A31}.theme-touraine-eschool{--recia-primary: #C60440;--recia-primary-light: #C60440;--recia-primary-inverted: #DD688C;--recia-primary-dark: #DD688C;--recia-btn-primary-pressed: #8B032D;--recia-btn-primary-pressed-light: #8B032D;--recia-btn-secondary-hover: #F9E6EC;--recia-btn-secondary-hover-light: #F9E6EC;--recia-btn-secondary-pressed: #F4CDD9;--recia-btn-secondary-pressed-light: #F4CDD9;--recia-btn-primary-pressed-inverted: #E89BB3;--recia-btn-primary-pressed-dark: #E89BB3;--recia-btn-secondary-hover-inverted: #211B1D;--recia-btn-secondary-hover-dark: #211B1D;--recia-btn-secondary-pressed-inverted: #352429;--recia-btn-secondary-pressed-dark: #352429}.theme-colleges-41{--recia-primary: #007EB4;--recia-primary-light: #007EB4;--recia-primary-inverted: #66B2D2;--recia-primary-dark: #66B2D2;--recia-btn-primary-pressed: #00587E;--recia-btn-primary-pressed-light: #00587E;--recia-btn-secondary-hover: #E6F2F8;--recia-btn-secondary-hover-light: #E6F2F8;--recia-btn-secondary-pressed: #CCE5F0;--recia-btn-secondary-pressed-light: #CCE5F0;--recia-btn-primary-pressed-inverted: #90CDE1;--recia-btn-primary-pressed-dark: #90CDE1;--recia-btn-secondary-hover-inverted: #1B1F20;--recia-btn-secondary-hover-dark: #1B1F20;--recia-btn-secondary-pressed-inverted: #232F33;--recia-btn-secondary-pressed-dark: #232F33}.theme-colleges-45{--recia-primary: #004899;--recia-primary-light: #004899;--recia-primary-inverted: #6691C2;--recia-primary-dark: #6691C2;--recia-btn-primary-pressed: #00326B;--recia-btn-primary-pressed-light: #00326B;--recia-btn-secondary-hover: #E6EDF5;--recia-btn-secondary-hover-light: #E6EDF5;--recia-btn-secondary-pressed: #CCDAEB;--recia-btn-secondary-pressed-light: #CCDAEB;--recia-btn-primary-pressed-inverted: #99B6D6;--recia-btn-primary-pressed-dark: #99B6D6;--recia-btn-secondary-hover-inverted: #1B1D20;--recia-btn-secondary-hover-dark: #1B1D20;--recia-btn-secondary-pressed-inverted: #232A31;--recia-btn-secondary-pressed-dark: #232A31}r-header,r-footer,extended-uportal-header,extended-uportal-footer{font-family:"DM Sans","sans-serif";font-style:normal;font-weight:normal;font-size:var(--recia-body-font-size);letter-spacing:0;color:var(--recia-body)}/*# sourceMappingURL=injectedStyle.css.map */</style>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="/resource-server/webjars/gip-recia__actualites/dist/actualites.min.js" type="module" defer></script>
            <script src="/resource-server/webjars/gip-recia__ui-webcomponents/dist/r-widgets-wrapper.js" type="module" defer></script>
          </head>
          <body style="margin:0; padding:10px; font-family:sans-serif;">
            <r-widgets-wrapper localization-uri="/commun/widgets/wrapper/20251013/i18n.json" soffit-uri="/portail/api/v5-1/userinfo?claims=private,ENTPersonGARIdentifiant,ESCOUAICourant,ESCOUAI,ENTPersonProfils&amp;groups=" widget-max-count="3" get-prefs-uri="/portail/api/prefs/getentityonlyprefs/Widgets" put-prefs-uri="/portail/api/prefs/putprefs?fname=Widgets" adapter-source-uri="/resource-server/webjars/gip-recia__widgets-to-endpoints-adapter/dist/widgets-to-endpoints-adapter.js" adapter-config-uri="/commun/widgets/adapter/20251013/adapter-configuration.json">
            </r-widgets-wrapper>
            <carrousel-ui user-info-api-url="/portail/api/v5-1/userinfo?claims=private&amp;groups=" get-user-news-url="/publisher/news/myNews/2" get-item-by-id-url="/publisher/news/item/" get-news-reading-informations-url="/publisher/news/readingInfos" set-reading-url="/publisher/news/setNewsReading/" all-news-page-url="/portail/p/News" dnma-fname="News" locale-key="News" use-reading-state="">
            </carrousel-ui>
          </body>
        </html>
      """,
                  mimeType: 'text/html',
                  encoding: 'utf-8',
                  baseUrl: WebUri("https://${AppConfig().uPortalBaseURL}"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true, // autoriser le JS
                ),
                onWebViewCreated: (controller) {
                  log.fine("Webview created in homepage");
                },
                onLoadStop: (controller, url) async {
                  log.fine("Webview in homepage finished loading");
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

}