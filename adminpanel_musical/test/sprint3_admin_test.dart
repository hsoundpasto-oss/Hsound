import 'package:flutter_test/flutter_test.dart';

// Lista de correos administradores autorizados (replica adminpanel_musical auth_service.dart)
const List<String> adminEmails = [
  'esneyderj.ibarra221@gmail.com',
  'esneydribarra1970@gmail.com',
  'sofia.burbanoba221@umariana.edu.co',
  'admin@musical.com',
];

bool isUserAdmin(String? email) {
  return email != null && adminEmails.contains(email);
}

// Función de búsqueda simulada (replica songs_screen.dart filter logic)
List<Map<String, dynamic>> searchSongsByTitle(
  List<Map<String, dynamic>> songs,
  String query,
) {
  if (query.isEmpty) return songs;
  final lowerQuery = query.toLowerCase();
  return songs.where((song) {
    final title = (song['title'] ?? '').toString().toLowerCase();
    return title.contains(lowerQuery);
  }).toList();
}

// Función de filtro por género (replica songs_screen.dart filter logic)
List<Map<String, dynamic>> filterByGenre(
  List<Map<String, dynamic>> songs,
  String? genre,
) {
  if (genre == null || genre == 'all') return songs;
  return songs.where((song) {
    return (song['genre'] ?? '') == genre;
  }).toList();
}

// Validación de estadísticas del dashboard
bool isValidDashboardStat(dynamic value) {
  if (value == null) return false;
  if (value is int) return value >= 0;
  if (value is double) return value >= 0 && value == value.floor();
  return false;
}

void main() {
  group('SPRINT 3 - PANEL ADMIN Y BÚSQUEDA', () {
    group('Validación de correos autorizados para admin', () {
      test('admin@musical.com debe poder iniciar sesión en el panel admin', () {
        expect(isUserAdmin('admin@musical.com'), isTrue);
      });

      test('esneydribarra1970@gmail.com debe poder iniciar sesión en el panel admin', () {
        expect(isUserAdmin('esneydribarra1970@gmail.com'), isTrue);
      });

      test('esneyderj.ibarra221@gmail.com debe poder iniciar sesión en el panel admin', () {
        expect(isUserAdmin('esneyderj.ibarra221@gmail.com'), isTrue);
      });

      test('sofia.burbanoba221@umariana.edu.co debe poder iniciar sesión en el panel admin', () {
        expect(isUserAdmin('sofia.burbanoba221@umariana.edu.co'), isTrue);
      });

      test('Un correo no autorizado debe ser rechazado', () {
        expect(isUserAdmin('usuario@gmail.com'), isFalse);
      });

      test('Correo nulo debe ser rechazado', () {
        expect(isUserAdmin(null), isFalse);
      });
    });

    group('Búsqueda de canciones por título', () {
      final sampleSongs = [
        {'title': 'Bohemian Rhapsody', 'artistName': 'Queen', 'genre': 'Rock'},
        {'title': 'Imagine', 'artistName': 'John Lennon', 'genre': 'Pop'},
        {'title': 'Billie Jean', 'artistName': 'Michael Jackson', 'genre': 'Pop'},
        {'title': 'Hotel California', 'artistName': 'Eagles', 'genre': 'Rock'},
      ];

      test('Búsqueda por título debe devolver resultados cuando existe la canción', () {
        final results = searchSongsByTitle(sampleSongs, 'Bohemian');
        expect(results.length, 1);
        expect(results[0]['title'], 'Bohemian Rhapsody');
      });

      test('Búsqueda por título debe devolver lista vacía cuando no hay resultados', () {
        final results = searchSongsByTitle(sampleSongs, 'NonExistentSongXYZ');
        expect(results, isEmpty);
      });

      test('Búsqueda con query vacío debe devolver todas las canciones', () {
        final results = searchSongsByTitle(sampleSongs, '');
        expect(results.length, 4);
      });
    });

    group('Filtro por género', () {
      final sampleSongs = [
        {'title': 'Bohemian Rhapsody', 'genre': 'Rock'},
        {'title': 'Imagine', 'genre': 'Pop'},
        {'title': 'Billie Jean', 'genre': 'Pop'},
        {'title': 'Hotel California', 'genre': 'Rock'},
      ];

      test('Filtro por género Rock debe mostrar solo canciones de Rock', () {
        final results = filterByGenre(sampleSongs, 'Rock');
        expect(results.length, 2);
        for (final song in results) {
          expect(song['genre'], 'Rock');
        }
      });

      test('Filtro por género Pop debe mostrar solo canciones de Pop', () {
        final results = filterByGenre(sampleSongs, 'Pop');
        expect(results.length, 2);
        for (final song in results) {
          expect(song['genre'], 'Pop');
        }
      });

      test('Filtro con "all" debe devolver todas las canciones', () {
        final results = filterByGenre(sampleSongs, 'all');
        expect(results.length, 4);
      });
    });

    group('Dashboard - validación de estadísticas', () {
      test('Total de usuarios debe ser un número entero no negativo', () {
        expect(isValidDashboardStat(0), isTrue);
        expect(isValidDashboardStat(10), isTrue);
        expect(isValidDashboardStat(150), isTrue);
        expect(isValidDashboardStat(-1), isFalse);
        expect(isValidDashboardStat(-5), isFalse);
      });

      test('Total de canciones debe ser un número entero no negativo', () {
        expect(isValidDashboardStat(0), isTrue);
        expect(isValidDashboardStat(25), isTrue);
        expect(isValidDashboardStat(-3), isFalse);
      });

      test('Total de artistas debe ser un número entero no negativo', () {
        expect(isValidDashboardStat(0), isTrue);
        expect(isValidDashboardStat(5), isTrue);
        expect(isValidDashboardStat(-1), isFalse);
      });

      test('Valores nulos no deben ser aceptados en el dashboard', () {
        expect(isValidDashboardStat(null), isFalse);
      });

      test('Valores decimales deben ser rechazados en el dashboard', () {
        expect(isValidDashboardStat(3.5), isFalse);
      });
    });
  });
}

// Ejecutar: flutter test test/sprint3_admin_test.dart
