import 'package:flutter_test/flutter_test.dart';

// Modelo de canción simplificado (replica song_model.dart copyWith)
class Song {
  final String id;
  final String title;
  final String artistName;
  final String genre;
  final bool isLiked;

  Song({
    required this.id,
    required this.title,
    required this.artistName,
    required this.genre,
    this.isLiked = false,
  });

  Song copyWith({bool? isLiked}) {
    return Song(
      id: id,
      title: title,
      artistName: artistName,
      genre: genre,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

// Simulación de lista de favoritos
class FavoritesService {
  final List<String> _favoriteIds = [];

  bool isFavorite(String songId) => _favoriteIds.contains(songId);

  void toggleFavorite(String songId) {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }
  }

  List<String> getFavoriteIds() => List.unmodifiable(_favoriteIds);

  int get favoriteCount => _favoriteIds.length;
}

// Simulación de gestión de usuarios por admin
class AdminUserService {
  final List<Map<String, dynamic>> _users = [];

  void addUser(Map<String, dynamic> user) => _users.add(user);

  List<Map<String, dynamic>> getAllUsers() => List.unmodifiable(_users);

  void makeArtist(String userId) {
    final index = _users.indexWhere((u) => u['id'] == userId);
    if (index != -1) {
      _users[index]['isArtist'] = true;
    }
  }

  bool isArtist(String userId) {
    final index = _users.indexWhere((u) => u['id'] == userId);
    return index != -1 && _users[index]['isArtist'] == true;
  }
}

void main() {
  group('SPRINT 4 - GESTIÓN DE USUARIOS Y FAVORITOS', () {
    group('Favoritos - Marcar/Quitar canciones', () {
      test('Marcar una canción como favorita debe cambiar isLiked a true', () {
        final song = Song(id: '1', title: 'Canción 1', artistName: 'Artista', genre: 'Rock');
        final updatedSong = song.copyWith(isLiked: true);
        expect(updatedSong.isLiked, isTrue);
        expect(song.isLiked, isFalse); // Original no debe mutarse
      });

      test('Quitar una canción de favoritos debe cambiar isLiked a false', () {
        final song = Song(id: '1', title: 'Canción 1', artistName: 'Artista', genre: 'Rock', isLiked: true);
        final updatedSong = song.copyWith(isLiked: false);
        expect(updatedSong.isLiked, isFalse);
      });

      test('Servicio de favoritos debe alternar el estado correctamente', () {
        final service = FavoritesService();
        expect(service.isFavorite('1'), isFalse);

        service.toggleFavorite('1');
        expect(service.isFavorite('1'), isTrue);

        service.toggleFavorite('1');
        expect(service.isFavorite('1'), isFalse);
      });
    });

    group('Lista de canciones favoritas', () {
      test('Usuario puede ver su lista de canciones favoritas', () {
        final service = FavoritesService();
        service.toggleFavorite('1');
        service.toggleFavorite('2');
        service.toggleFavorite('3');

        final favorites = service.getFavoriteIds();
        expect(favorites.length, 3);
        expect(favorites, containsAll(['1', '2', '3']));
      });

      test('Lista de favoritos debe estar vacía inicialmente', () {
        final service = FavoritesService();
        expect(service.getFavoriteIds(), isEmpty);
      });
    });

    group('Administrador - Gestión de usuarios', () {
      test('Administrador puede ver la lista completa de usuarios', () {
        final adminService = AdminUserService();
        adminService.addUser({'id': '1', 'name': 'Alice', 'isArtist': false});
        adminService.addUser({'id': '2', 'name': 'Bob', 'isArtist': true});
        adminService.addUser({'id': '3', 'name': 'Charlie', 'isArtist': false});

        final allUsers = adminService.getAllUsers();
        expect(allUsers.length, 3);
      });

      test('Administrador puede convertir un usuario en artista', () {
        final adminService = AdminUserService();
        adminService.addUser({'id': '1', 'name': 'Alice', 'isArtist': false});

        expect(adminService.isArtist('1'), isFalse);

        adminService.makeArtist('1');
        expect(adminService.isArtist('1'), isTrue);
      });

      test('Convertir a artista solo afecta al usuario especificado', () {
        final adminService = AdminUserService();
        adminService.addUser({'id': '1', 'name': 'Alice', 'isArtist': false});
        adminService.addUser({'id': '2', 'name': 'Bob', 'isArtist': false});

        adminService.makeArtist('1');
        expect(adminService.isArtist('1'), isTrue);
        expect(adminService.isArtist('2'), isFalse);
      });
    });
  });
}

// Ejecutar: flutter test test/sprint4_favoritos_test.dart
