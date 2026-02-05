import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class ChangeEtabService {
  final log = Logger('ChangeEtabService');

  ChangeEtabService._privateConstructor();

  static final ChangeEtabService _instance =
      ChangeEtabService._privateConstructor();

  static ChangeEtabService get instance => _instance;

  Future<bool> changeEtab(String token, String siren) async {
    final url =
        "https://lycees.netocentre.fr/paramuseretab/changeetab/api/$siren";
    log.fine("Making a request to $url");
    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      return false;
    }
    return true;
  }

  Future<void> partialLogout() async {
    // TODO
  }

  Future<void> clearPortalSession() async {
    // TODO
  }
}
