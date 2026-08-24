import 'package:url_launcher/url_launcher.dart';

class Utils {
  Future<String> openLink({required String url}) async {
    if(!await launchUrl(Uri.parse(url))) {
      return "Cannot Launch.";
    } else {
      return "URL Launched Successfully";
    }
  }
}
