import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/song_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Usuario no autenticado');

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  profileData['email'] = user.email;

  final existingUser = await userRef.get();

  if (existingUser.exists) {
    final existingData = existingUser.data()!;

    if (existingData['name'] != null && existingData['name'].isNotEmpty) {
      profileData['name'] = existingData['name'];
    }

    if (existingData['isArtist'] != null) {
      profileData['isArtist'] = existingData['isArtist'];
    }

    if (existingData['createdAt'] == null) {
      profileData['createdAt'] = FieldValue.serverTimestamp();
    }

    profileData['updatedAt'] = FieldValue.serverTimestamp();
    await userRef.update(profileData);
  } else {
    profileData['createdAt'] = FieldValue.serverTimestamp();
    profileData['updatedAt'] = FieldValue.serverTimestamp();
    profileData['isArtist'] = false;
    final name = profileData['name'] as String? ?? '';
    profileData['searchKeywords'] = createSearchKeywords(name);
    await userRef.set(profileData);
  }
}

  // Obtener perfil de usuario
  Future<DocumentSnapshot> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    return await _firestore.collection('users').doc(user.uid).get();
  }

  // Obtener perfil de usuario como Stream (para updates en tiempo real)
  Stream<DocumentSnapshot> getUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // Método para convertir URLs normales a embed URLs (opcional)
  String convertToEmbedUrl(String url, String platform) {
    switch (platform) {
      case 'youtube':
        if (url.contains('youtu.be/')) {
          final videoId = url.split('youtu.be/').last.split('?').first;
          return 'https://www.youtube.com/embed/$videoId';
        } else if (url.contains('watch?v=')) {
          final videoId = url.split('v=').last.split('&').first;
          return 'https://www.youtube.com/embed/$videoId';
        }
        break;

      case 'spotify':
        if (url.contains('spotify.com/track/')) {
          final trackId = url.split('track/').last.split('?').first;
          return 'https://open.spotify.com/embed/track/$trackId';
        }
        break;
    }

    return url; // Devolver original si no se puede convertir
  }

  //  Guardar canción usando el modelo Song
  Future<void> saveSong(Song song) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('songs').add(song.toFirestore());
    }
  }

  // Obtener canciones del artista
  Stream<QuerySnapshot> getArtistSongs(String artistId) {
    return _firestore
        .collection('songs')
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obtener todas las canciones (para explorar)
  Stream<QuerySnapshot> getAllSongs() {
    return _firestore
        .collection('songs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obtener canciones por género
  Stream<QuerySnapshot> getSongsByGenre(String genre) {
    return _firestore
        .collection('songs')
        .where('genre', isEqualTo: genre)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Eliminar canción
  Future<void> deleteSong(String songId) async {
    try {
      await _firestore.collection('songs').doc(songId).delete();
      print('Canción $songId eliminada exitosamente');
    } catch (e) {
      print('Error al eliminar canción: $e');
      throw e;
    }
  }

  Stream<QuerySnapshot> searchSongs({
    required String query,
    String? genre,
    String? sortBy,
    int limit = 20,
  }) {
    Query searchQuery = _firestore.collection('songs');

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      searchQuery =
          searchQuery.where('searchKeywords', arrayContains: lowerQuery);
    }

    if (genre != null && genre.isNotEmpty && genre != 'Todos') {
      searchQuery = searchQuery.where('genre', isEqualTo: genre);
    }

    switch (sortBy) {
      case 'popularity':
        searchQuery = searchQuery.orderBy('likes', descending: true);
        break;
      case 'date':
        searchQuery = searchQuery.orderBy('createdAt', descending: true);
        break;
      case 'title':
      default:
        searchQuery = searchQuery.orderBy('title', descending: false);
        break;
    }

    return searchQuery.limit(limit).snapshots().handleError((error) {
      return _fallbackSearch(query: query, genre: genre, sortBy: sortBy, limit: limit);
    });
  }

  Stream<QuerySnapshot> _fallbackSearch({
    required String query,
    String? genre,
    String? sortBy,
    int limit = 20,
  }) {
    Query searchQuery = _firestore.collection('songs');

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      searchQuery = searchQuery
          .where('searchKeywords', arrayContains: lowerQuery);
    }

    return searchQuery.limit(limit).snapshots();
  }

  Stream<QuerySnapshot> searchArtists({
    required String query,
    int limit = 10,
  }) {
    if (query.isEmpty) {
      return _firestore
          .collection('users')
          .where('isArtist', isEqualTo: true)
          .limit(limit)
          .snapshots();
    }

    final lowerQuery = query.toLowerCase();

    return _firestore
        .collection('users')
        .where('isArtist', isEqualTo: true)
        .where('searchKeywords', arrayContains: lowerQuery)
        .limit(limit)
        .snapshots();
  }

  // Obtener géneros únicos para filtros
  Future<List<String>> getAvailableGenres() async {
    final snapshot =
        await _firestore.collection('songs').orderBy('genre').get();

    final genres = snapshot.docs
        .map((doc) => doc['genre'] as String? ?? 'General')
        .toSet()
        .toList();

    return genres..sort();
  }

  // Función para crear keywords de búsqueda
  List<String> createSearchKeywords(String text) {
    if (text.isEmpty) return [];

    final words = text.toLowerCase().split(' ');
    final keywords = <String>[];

    for (final word in words) {
      if (word.trim().isNotEmpty) {
        // Agregar la palabra completa
        keywords.add(word.trim());

        // Agregar substrings para búsqueda parcial (solo palabras de 3+ caracteres)
        if (word.trim().length > 2) {
          for (int i = 1; i <= word.trim().length; i++) {
            final substring = word.trim().substring(0, i);
            if (substring.length >= 2) {
              // Solo substrings de 2+ caracteres
              keywords.add(substring);
            }
          }
        }
      }
    }

    // Agregar el texto completo en minúsculas
    keywords.add(text.toLowerCase().trim());

    return keywords.toSet().toList(); // Remover duplicados
  }

  // ✅ NUEVA: Función para actualizar canciones existentes con searchKeywords
  Future<void> updateSongsWithSearchKeywords() async {
    try {
      final snapshot = await _firestore.collection('songs').get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final title = data['title'] as String? ?? '';
        final artistName = data['artistName'] as String? ?? '';

        // Crear keywords combinando título y artista
        final searchKeywords = createSearchKeywords('$title $artistName');

        // Actualizar el documento
        await _firestore.collection('songs').doc(doc.id).update({
          'searchKeywords': searchKeywords,
        });

        print('Cancion ${doc.id} actualizada con keywords');
      }
    } catch (e) {
      print('Error actualizando keywords: $e');
    }
  }
  Future<void> updateUsersWithSearchKeywords() async {
  final users = await FirebaseFirestore.instance.collection('users').get();
  
  for (final user in users.docs) {
    final data = user.data();
    final name = data['name'] ?? '';
    final email = data['email'] ?? '';
    
    final searchKeywords = createSearchKeywords('$name $email');
    
    await user.reference.update({
      'searchKeywords': searchKeywords,
    });
  }
}
Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Usuario no autenticado');

  if (user.email != null) {
    profileData['email'] = user.email;
  }

  if (profileData.containsKey('name')) {
    final name = profileData['name'] as String? ?? '';
    profileData['searchKeywords'] = createSearchKeywords(name);
  }

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update(profileData);
}

// TOGGLE LIKE/FAVORITO
  Future<void> toggleLike(String songId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuario no autenticado');
      return;
    }

    final likeId = '${user.uid}_$songId';
    final likeRef = _firestore.collection('userLikes').doc(likeId);

    try {
      // ✅ PRIMERO verificamos si existe usando una transacción o método más seguro
      final songRef = _firestore.collection('songs').doc(songId);

      // Usamos una transacción para asegurar consistencia
      await _firestore.runTransaction((transaction) async {
        // Verificamos si el like existe
        final likeDoc = await transaction.get(likeRef);

        if (likeDoc.exists) {
          print('Eliminando like existente...');
          transaction.delete(likeRef);
          transaction.update(songRef, {'likes': FieldValue.increment(-1)});
        } else {
          print('Creando nuevo like...');
          transaction.set(likeRef, {
            'userId': user.uid,
            'songId': songId,
            'createdAt': FieldValue.serverTimestamp()
          });
          transaction.update(songRef, {'likes': FieldValue.increment(1)});
        }
      });

      print('Operacion de like completada exitosamente');
    } catch (e) {
      print('Error en toggleLike: $e');

      if (e.toString().contains('PERMISSION_DENIED')) {
        print('Error de permisos. Verifica las reglas de Firestore.');
      } else if (e.toString().contains('NOT_FOUND')) {
        print('Documento no encontrado.');
      } else {
        print('Error desconocido.');
      }

      rethrow;
    }
  }

// ✅ VERIFICAR SI UNA CANCIÓN ESTÁ LIKEADA
  Future<bool> isSongLiked(String songId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final likeDoc = await _firestore
        .collection('userLikes')
        .doc('${user.uid}_$songId')
        .get();

    return likeDoc.exists;
  }

// ✅ OBTENER CANCIONES FAVORITAS DEL USUARIO
  Stream<QuerySnapshot> getUserFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _firestore
          .collection('songs')
          .where('dummy', isEqualTo: 'dummy')
          .snapshots();
    }

    return _firestore
        .collection('userLikes')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((likesSnapshot) async {
      if (likesSnapshot.docs.isEmpty) {
        return _firestore
            .collection('songs')
            .where('dummy', isEqualTo: 'dummy')
            .get();
      }

      final songIds =
          likesSnapshot.docs.map((doc) => doc['songId'] as String).toList();

      return await _firestore
          .collection('songs')
          .where(FieldPath.documentId, whereIn: songIds)
          .get();
    });
  }

// ✅ OBTENER LIKES EN TIEMPO REAL (para actualizar contadores)
  Stream<DocumentSnapshot> getSongLikesStream(String songId) {
    return _firestore.collection('songs').doc(songId).snapshots();
  }
}
