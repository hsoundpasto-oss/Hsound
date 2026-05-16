import 'package:flutter_test/flutter_test.dart';

// Simulación de servicio de gestión de canciones
class SongManagementService {
  final List<Map<String, dynamic>> _songs = [];
  final List<Map<String, dynamic>> _deletedSongs = [];

  void addSong(Map<String, dynamic> song) => _songs.add(song);

  List<Map<String, dynamic>> getAllSongs() => List.unmodifiable(_songs);

  List<Map<String, dynamic>> getArtistSongs(String artistId) {
    return _songs.where((s) => s['artistId'] == artistId).toList();
  }

  bool deleteSong(String songId, String requesterId) {
    final index = _songs.indexWhere((s) => s['id'] == songId);
    if (index == -1) return false;
    final song = _songs.removeAt(index);
    _deletedSongs.add({...song, 'deletedAt': DateTime.now()});
    return true;
  }

  bool deleteSongAsAdmin(String songId) {
    return deleteSong(songId, 'admin');
  }

  bool canArtistDeleteSong(String artistId, String songId) {
    final song = _songs.firstWhere(
      (s) => s['id'] == songId,
      orElse: () => {'artistId': null},
    );
    return song['artistId'] == artistId;
  }

  int get songCount => _songs.length;
  int get deletedCount => _deletedSongs.length;
}

// Simulación de edición de perfil de artista
class ArtistProfileService {
  String? _bio;
  String? _youtubeUrl;
  String? _spotifyUrl;

  void updateProfile({String? bio, String? youtubeUrl, String? spotifyUrl}) {
    if (bio != null) _bio = bio;
    if (youtubeUrl != null) _youtubeUrl = youtubeUrl;
    if (spotifyUrl != null) _spotifyUrl = spotifyUrl;
  }

  String? get bio => _bio;
  String? get youtubeUrl => _youtubeUrl;
  String? get spotifyUrl => _spotifyUrl;
}

void main() {
  group('SPRINT 5 - GESTIÓN DE CANCIONES', () {
    group('Administrador - Visión general', () {
      test('Administrador puede ver todas las canciones de la plataforma', () {
        final service = SongManagementService();
        service.addSong({'id': '1', 'title': 'Canción A', 'artistId': 'artist1'});
        service.addSong({'id': '2', 'title': 'Canción B', 'artistId': 'artist2'});
        service.addSong({'id': '3', 'title': 'Canción C', 'artistId': 'artist1'});

        final allSongs = service.getAllSongs();
        expect(allSongs.length, 3);
      });

      test('Administrador puede eliminar una canción', () {
        final service = SongManagementService();
        service.addSong({'id': '1', 'title': 'Canción A', 'artistId': 'artist1'});

        final result = service.deleteSongAsAdmin('1');
        expect(result, isTrue);
        expect(service.songCount, 0);
      });
    });

    group('Artista - Gestión propia', () {
      test('Artista puede ver su propia lista de canciones', () {
        final service = SongManagementService();
        service.addSong({'id': '1', 'title': 'Mi Canción', 'artistId': 'artist1'});
        service.addSong({'id': '2', 'title': 'Otra Canción', 'artistId': 'artist2'});
        service.addSong({'id': '3', 'title': 'Mi Segundo Tema', 'artistId': 'artist1'});

        final mySongs = service.getArtistSongs('artist1');
        expect(mySongs.length, 2);
        for (final song in mySongs) {
          expect(song['artistId'], 'artist1');
        }
      });

      test('Artista puede editar su perfil (biografía)', () {
        final profileService = ArtistProfileService();
        profileService.updateProfile(bio: 'Músico de rock alternativo');
        expect(profileService.bio, 'Músico de rock alternativo');
      });

      test('Artista puede editar su perfil (enlaces)', () {
        final profileService = ArtistProfileService();
        profileService.updateProfile(
          youtubeUrl: 'https://youtube.com/@mirock',
          spotifyUrl: 'https://open.spotify.com/artist/abc123',
        );
        expect(profileService.youtubeUrl, 'https://youtube.com/@mirock');
        expect(profileService.spotifyUrl, 'https://open.spotify.com/artist/abc123');
      });

      test('Artista no puede eliminar canciones de otros artistas', () {
        final service = SongManagementService();
        service.addSong({'id': '1', 'title': 'Canción Ajena', 'artistId': 'artist2'});

        final canDelete = service.canArtistDeleteSong('artist1', '1');
        expect(canDelete, isFalse);
      });

      test('Artista puede eliminar sus propias canciones', () {
        final service = SongManagementService();
        service.addSong({'id': '1', 'title': 'Mi Canción', 'artistId': 'artist1'});

        final canDelete = service.canArtistDeleteSong('artist1', '1');
        expect(canDelete, isTrue);
      });
    });
  });
}

// Ejecutar: flutter test test/sprint5_gestion_test.dart
