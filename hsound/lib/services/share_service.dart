import 'package:share_plus/share_plus.dart';

class ShareService {
  static const String downloadUrl = 'https://drive.google.com/drive/folders/11coN6w5jWHiFhzWn-cMqA5BRtXO1eZn6?usp=sharing';

  static Future<void> shareSong({
    required String songTitle,
    required String artistName,
  }) async {
    final String text = 'Escucha "$songTitle" por $artistName\n'
                        'Descarga HSound para mas musica de Pasto:\n'
                        '$downloadUrl';

    await Share.share(text);
  }

  static Future<void> shareArtistProfile({
    required String artistName,
    String? bio,
  }) async {
    final String bioText = bio != null ? '\n$bio' : '';
    final String text = 'Conoce a $artistName en HSound!$bioText\n'
                        'Descarga la app para ver su musica:\n'
                        '$downloadUrl';

    await Share.share(text);
  }

  static Future<void> shareEvent(String eventText) async {
    await Share.share(eventText);
  }

  static Future<void> shareApp() async {
    const String text = 'Descarga HSound - La app de musica de Pasto!\n'
                        'Encuentra artistas locales y nueva musica\n'
                        'Descarga gratis:\n'
                        '$downloadUrl';

    await Share.share(text);
  }
}