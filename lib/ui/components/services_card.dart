import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:libresco/objects/service.dart';
import 'package:libresco/objects/singletons/account.dart';
import 'package:libresco/objects/singletons/app_config.dart';
import 'package:libresco/objects/singletons/session.dart';
import 'package:libresco/services/dnma_service.dart';
import 'package:libresco/services/login_service.dart';
import 'package:libresco/ui/pages/unconnected_home_page.dart';
import 'package:libresco/ui/pages/web_view_page.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicesCard extends StatelessWidget {
  final log = Logger('ServicesCard');
  final Service service;
  final VoidCallback? onPressed;

  ServicesCard(
    this.service, {
    super.key,
    required this.onPressed,
  });

  void markDNMA(String dimension, String fname, String url) {
    if (AppConfig().markedFnames.contains(fname)) {
      log.fine("Marking access to service $fname by DNMA");
      DnmaService.instance.mark(dimension, fname, url);
    } else {
      log.fine("Access to service $fname will not be marked by DNMA");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 4,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onTapUp: (_) async {
          bool launchWeb = false;
          if (AppConfig().externalServices.containsKey(service.fname)) {
            log.fine("External service detected : ${service.fname}");
            String url = AppConfig().externalServices[service.fname]!;
            try {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
              markDNMA(AppConfig().dnmaDimension, service.fname!, url);
            } catch (e) {
              log.warning('Unable to open app $url with error $e');
              launchWeb = true;
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Impossible d\'ouvrir l\'application externe : est-elle installée sur votre téléphone ?',
                    ),
                    duration: Duration(seconds: 5),
                  ),
                );
              }
            }
          } else {
            launchWeb = true;
          }

          final String baseUrl = Account().getBaseUrl();
          log.finer('Base url for user is $baseUrl');

          if (launchWeb) {
            if (await LoginService.instance.hasCASSession() && await LoginService.instance.isAuthorizedByUPortal()) {
              if (context.mounted) {
                String uri = '$baseUrl/portail/p/${service.serviceUri}';
                if (!service.isAuthByUPortal) {
                  uri = '$baseUrl'
                      '/portail/api/ExternalURLStats'
                      '?fname=${service.fname}'
                      '&service=${service.serviceUri}';
                }
                log.finer(
                  'define url from uri \'${service.serviceUri}\' : $uri',
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(
                      appBarTitle: service.text,
                      uri: uri,
                    ),
                  ),
                );
                markDNMA(AppConfig().dnmaDimension, service.fname!, uri);
              }
            } else {
              Session().clear(persist: true);
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnconnectedHomePage(),
                  ),
                );
              }
            }
          }
        },
        child: Center(
          child: Stack(
            key: Key(service.text),
            children: [
              Column(
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      color: AppConfig().getColorFromCategoryId(service.category),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LogoRow(
                    service,
                    onPressed: onPressed,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppConfig().getNameFromCategoryId(service.category),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    service.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Container(
              //     padding: const EdgeInsets.only(bottom: 10),
              //     child: TextButton(
              //       onPressed: () => log.finer('click on En savoir plus'),
              //       child: const Text(
              //         'En savoir plus',
              //         style: TextStyle(
              //           fontWeight: FontWeight.w700,
              //           color: Colors.blue,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoRow extends StatelessWidget {
  final log = Logger('LogoRow');
  final Service service;
  final VoidCallback? onPressed;

  LogoRow(this.service, {super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (service.isNew)
          Positioned(
            left: 5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xFFad1919),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: const Text(
                'Nouveau',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        Align(
          alignment: Alignment.center,
          child: SvgPicture.network(
            '${Account().getBaseUrl()}${service.iconUri}',
            height: 50,
            width: 50,
            colorFilter: ColorFilter.mode(
              AppConfig().getColorFromCategoryId(service.category),
              BlendMode.srcIn,
            ),
          ),
        ),
        if (service.isFavorite)
          Positioned(
            right: 5,
            child: TextButton(
              onPressed: onPressed,
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFF1C903),
                size: 32.0,
              ),
            ),
          )
        else
          Positioned(
            right: 5,
            child: TextButton(
              onPressed: onPressed,
              child: Icon(
                Icons.star_border_rounded,
                color: Colors.grey.shade600,
                size: 32.0,
              ),
            ),
          )
      ],
    );
  }
}
