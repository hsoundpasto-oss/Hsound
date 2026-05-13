import 'package:share_plus/share_plus.dart';

class ShareService {
  // 🎯 ENLACE DE LA CARPETA (FIJO PARA SIEMPRE)
  static const String downloadUrl = 'https://drive.google.com/drive/folders/1TZy9AYGr9wv6rrgUPq2qNNhpcG2hUrL8';

  // Compartir canción + enlace descarga
  static Future<void> shareSong({
    required String songTitle,
    required String artistName,
  }) async {
    final String text = '🎵 Escucha "$songTitle" por $artistName\n'
                        '👇 Descarga HSound para más música de Pasto:\n'
                        '$downloadUrl';
    
    await Share.share(text);
  }

  // Compartir perfil de artista + enlace descarga
  static Future<void> shareArtistProfile({
    required String artistName,
    String? bio,
  }) async {
    final String bioText = bio != null ? '\n$bio' : '';
    final String text = '👤 Conoce a $artistName en HSound!$bioText\n'
                        '👇 Descarga la app para ver su música:\n'
                        '$downloadUrl';
    
    await Share.share(text);
  }

  // Compartir app HSound
  static Future<void> shareApp() async {
    const String text = '🎵 Descarga HSound - La app de música de Pasto!\n'
                        'Encuentra artistas locales y nueva música 🎶\n'
                        '👇 Descarga gratis:\n'
                        '$downloadUrl';
    
    await Share.share(text);
  }
}