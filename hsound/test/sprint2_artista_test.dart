import 'package:flutter_test/flutter_test.dart';

// Funciones de validación que replican la lógica de add_song_screen.dart y edit_profile_screen.dart
String? validateArtistName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu nombre';
  }
  if (value.length < 2) {
    return 'El nombre debe tener al menos 2 caracteres';
  }
  return null;
}

String? validateYoutubeUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return 'La URL debe comenzar con http:// o https://';
  }
  if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
    return 'URL de YouTube no válida. Debe ser de youtube.com o youtu.be';
  }
  return null;
}

String? validateSpotifyUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return 'La URL debe comenzar con http:// o https://';
  }
  if (!value.contains('spotify.com') && !value.contains('open.spotify.com')) {
    return 'URL de Spotify no válida. Debe ser de open.spotify.com';
  }
  if (!value.contains('/track/')) {
    return 'URL de Spotify debe ser de un track específico (contener /track/)';
  }
  return null;
}

String? validateSoundcloudUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!value.contains('soundcloud.com')) {
    return 'URL de SoundCloud no valida';
  }
  return null;
}

String? validateGenre(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor selecciona un género';
  }
  return null;
}

void main() {
  group('SPRINT 2 - PERFIL DE ARTISTA Y CANCIONES', () {
    group('Validación del nombre del artista', () {
      test('Nombre del artista vacío debe ser rechazado', () {
        final result = validateArtistName('');
        expect(result, isNotNull);
        expect(result, 'Por favor ingresa tu nombre');
      });

      test('Nombre del artista nulo debe ser rechazado', () {
        final result = validateArtistName(null);
        expect(result, isNotNull);
        expect(result, 'Por favor ingresa tu nombre');
      });

      test('Nombre del artista con menos de 2 caracteres debe ser rechazado', () {
        final result = validateArtistName('A');
        expect(result, isNotNull);
        expect(result, 'El nombre debe tener al menos 2 caracteres');
      });

      test('Nombre del artista válido debe ser aceptado', () {
        final result = validateArtistName('Juanes');
        expect(result, isNull);
      });
    });

    group('Validación de URL de YouTube', () {
      test('URL de YouTube con youtube.com debe ser válida', () {
        final result = validateYoutubeUrl('https://youtube.com/watch?v=dQw4w9WgXcQ');
        expect(result, isNull);
      });

      test('URL de YouTube con youtu.be debe ser válida', () {
        final result = validateYoutubeUrl('https://youtu.be/dQw4w9WgXcQ');
        expect(result, isNull);
      });

      test('URL que no contiene youtube.com ni youtu.be debe ser rechazada', () {
        final result = validateYoutubeUrl('https://vimeo.com/12345');
        expect(result, isNotNull);
        expect(result, contains('youtube.com o youtu.be'));
      });
    });

    group('Validación de URL de Spotify', () {
      test('URL de Spotify con spotify.com y /track/ debe ser válida', () {
        final result = validateSpotifyUrl('https://open.spotify.com/track/4cOdK2wGLETKBW3PvgPWqT');
        expect(result, isNull);
      });

      test('URL de Spotify sin /track/ debe ser rechazada', () {
        final result = validateSpotifyUrl('https://open.spotify.com/artist/4cOdK2wGLETKBW3PvgPWqT');
        expect(result, isNotNull);
        expect(result, contains('/track/'));
      });

      test('URL que no contiene spotify.com debe ser rechazada', () {
        final result = validateSpotifyUrl('https://deezer.com/track/12345');
        expect(result, isNotNull);
        expect(result, contains('spotify.com'));
      });
    });

    group('Validación de URL de SoundCloud', () {
      test('URL de SoundCloud con soundcloud.com debe ser válida', () {
        final result = validateSoundcloudUrl('https://soundcloud.com/artista/cancion');
        expect(result, isNull);
      });

      test('URL que no contiene soundcloud.com debe ser rechazada', () {
        final result = validateSoundcloudUrl('https://mixcloud.com/artista/cancion');
        expect(result, isNotNull);
        expect(result, 'URL de SoundCloud no valida');
      });
    });

    group('Validación del género musical', () {
      test('Género musical vacío debe ser rechazado al agregar canción', () {
        final result = validateGenre('');
        expect(result, isNotNull);
        expect(result, 'Por favor selecciona un género');
      });

      test('Género musical nulo debe ser rechazado', () {
        final result = validateGenre(null);
        expect(result, isNotNull);
      });

      test('Género musical válido debe ser aceptado', () {
        final result = validateGenre('Rock');
        expect(result, isNull);
      });
    });
  });
}

// Ejecutar: flutter test test/sprint2_artista_test.dart
