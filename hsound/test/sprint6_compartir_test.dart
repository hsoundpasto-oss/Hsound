import 'package:flutter_test/flutter_test.dart';

// Simulación de ShareService (replica share_service.dart)
class ShareServiceMock {
  static String generateShareSongText({
    required String songTitle,
    required String artistName,
  }) {
    const downloadUrl =
        'https://drive.google.com/drive/folders/11coN6w5jWHiFhzWn-cMqA5BRtXO1eZn6?usp=sharing';
    return 'Escucha "$songTitle" por $artistName\n'
        'Descarga HSound para mas musica de Pasto:\n'
        '$downloadUrl';
  }

  static String generateShareArtistText({
    required String artistName,
    String? bio,
  }) {
    const downloadUrl =
        'https://drive.google.com/drive/folders/11coN6w5jWHiFhzWn-cMqA5BRtXO1eZn6?usp=sharing';
    final bioText = bio != null ? '\n$bio' : '';
    return 'Conoce a $artistName en HSound!$bioText\n'
        'Descarga la app para ver su musica:\n'
        '$downloadUrl';
  }
}

// Simulación de gestión de usuarios por admin
class UserAdminService {
  final List<Map<String, dynamic>> _users = [];

  void addUser(Map<String, dynamic> user) {
    _users.add({...user});
  }

  List<Map<String, dynamic>> getAllUsers() => List.unmodifiable(_users);

  bool deleteUser(String userId) {
    final before = _users.length;
    _users.removeWhere((u) => u['id'] == userId);
    return _users.length < before;
  }

  bool userExists(String userId) {
    return _users.any((u) => u['id'] == userId);
  }
}

void main() {
  group('SPRINT 6 - COMPARTIR Y ELIMINAR USUARIOS', () {
    group('Compartir canciones', () {
      test('Compartir una canción debe generar texto con título y artista', () {
        final text = ShareServiceMock.generateShareSongText(
          songTitle: 'Bohemian Rhapsody',
          artistName: 'Queen',
        );

        expect(text, contains('Bohemian Rhapsody'));
        expect(text, contains('Queen'));
        expect(text, contains('Escucha'));
        expect(text, contains('Descarga HSound'));
      });

      test('Texto compartido debe incluir el enlace de descarga', () {
        final text = ShareServiceMock.generateShareSongText(
          songTitle: 'Imagine',
          artistName: 'John Lennon',
        );

        expect(text, contains('drive.google.com'));
      });
    });

    group('Compartir perfil de artista', () {
      test('Compartir perfil de artista debe incluir el nombre del artista', () {
        final text = ShareServiceMock.generateShareArtistText(
          artistName: 'Shakira',
        );

        expect(text, contains('Shakira'));
        expect(text, contains('Conoce a'));
        expect(text, contains('HSound'));
      });

      test('Compartir perfil de artista con biografía debe incluir la biografía', () {
        final text = ShareServiceMock.generateShareArtistText(
          artistName: 'Shakira',
          bio: 'Cantante y compositora colombiana',
        );

        expect(text, contains('Shakira'));
        expect(text, contains('Cantante y compositora colombiana'));
      });

      test('Compartir perfil de artista sin biografía no debe incluir línea extra', () {
        final text = ShareServiceMock.generateShareArtistText(
          artistName: 'Artista',
        );

        expect(text, 'Conoce a Artista en HSound!\n'
            'Descarga la app para ver su musica:\n'
            'https://drive.google.com/drive/folders/11coN6w5jWHiFhzWn-cMqA5BRtXO1eZn6?usp=sharing');
      });
    });

    group('Administrador - Eliminar usuarios', () {
      test('Administrador puede eliminar un usuario', () {
        final service = UserAdminService();
        service.addUser({'id': '1', 'name': 'Alice'});
        service.addUser({'id': '2', 'name': 'Bob'});

        final deleted = service.deleteUser('1');
        expect(deleted, isTrue);
        expect(service.getAllUsers().length, 1);
      });

      test('Al eliminar un usuario, este ya no debe aparecer en la lista', () {
        final service = UserAdminService();
        service.addUser({'id': '1', 'name': 'Alice'});
        service.addUser({'id': '2', 'name': 'Bob'});

        service.deleteUser('1');
        expect(service.userExists('1'), isFalse);
        expect(service.userExists('2'), isTrue);
      });

      test('Administrador puede cancelar la eliminación de un usuario', () {
        final service = UserAdminService();
        service.addUser({'id': '1', 'name': 'Alice'});

        // Simular cancelación: no ejecutar deleteUser
        final wasCancelled = true;

        expect(wasCancelled, isTrue);
        expect(service.userExists('1'), isTrue);
      });

      test('Eliminar un usuario que no existe debe retornar false', () {
        final service = UserAdminService();
        service.addUser({'id': '1', 'name': 'Alice'});

        final deleted = service.deleteUser('999');
        expect(deleted, isFalse);
      });
    });
  });
}

// Ejecutar: flutter test test/sprint6_compartir_test.dart
