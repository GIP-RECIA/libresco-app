import 'package:logging/logging.dart';

class WebViewUtils {
  static final log = Logger('WebViewUtils');

  static bool isInsideNavigation(String host) {
    return RegExp(
            r'^(+*.elea\.apps\.education\.fr|visio-ent\.recia\.fr|capytale2\.ac-paris\.fr|lycees\.netocentre\.fr|mon-e-college\.loiret\.fr|www\.colleges-eureliens\.fr|cfa\.netocentre\.fr|www\.chercan\.fr|e-college\.indre\.fr|www\.touraine-eschool\.fr|ent\.colleges41\.fr|ent\.recia\.fr|formations-sociales\.netocentre\.fr|(pads[^.]*\.((netocentre)|(recia))\.fr)|(pads\.((touraine-eschool)|(chercan)|(colleges41)|(colleges-eureliens)|(e-college\.indre)|(mon-e-college\.loiret))\.fr)|(pdf-online\.((netocentre)|(touraine-eschool)|(colleges41)|(chercan)|(e-college\.indre)|(mon-e-college\.loiret)|(colleges-eureliens)|(recia))\.fr)|(nc\.touraine-eschool\.fr|nc\.chercan\.fr|nc\.colleges41\.fr|nc\.e-college\.indre\.fr|nc\.mon-e-college\.loiret\.fr|nc\.colleges-eureliens\.fr|((nc-[^.]*\.netocentre)|((nc-ent)\.recia))\.fr)|(auth\.recia\.fr))')
        .hasMatch(host);
  }
}
