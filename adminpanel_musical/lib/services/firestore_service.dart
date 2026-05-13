import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener estadísticas para el dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Obtener total de usuarios
      final usersSnapshot = await _firestore.collection('users').count().get();
      final totalUsers = usersSnapshot.count;

      // Obtener total de artistas
      final artistsSnapshot = await _firestore
          .collection('users')
          .where('isArtist', isEqualTo: true)
          .count()
          .get();
      final totalArtists = artistsSnapshot.count;

      // Obtener total de canciones
      final songsSnapshot = await _firestore.collection('songs').count().get();
      final totalSongs = songsSnapshot.count;

      return {
        'totalUsers': totalUsers,
        'totalArtists': totalArtists,
        'totalSongs': totalSongs,
        'pendingApprovals': 0, // Puedes implementar esto después
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalUsers': 0,
        'totalArtists': 0, 
        'totalSongs': 0,
        'pendingApprovals': 0,
      };
    }
  }

  // Obtener todos los usuarios
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obtener usuarios recientes
  Stream<QuerySnapshot> getRecentUsers({int limit = 5}) {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Obtener todas las canciones
  Stream<QuerySnapshot> getAllSongs() {
    return _firestore
        .collection('songs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obtener canciones recientes
  Stream<QuerySnapshot> getRecentSongs({int limit = 5}) {
    return _firestore
        .collection('songs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Actualizar rol de usuario
  Future<void> updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'role': newRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Convertir usuario a artista
  Future<void> makeUserArtist(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isArtist': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Convertir artista a usuario normal
  Future<void> removeArtistRole(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isArtist': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Eliminar usuario
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Eliminar canción
  Future<void> deleteSong(String songId) async {
    await _firestore.collection('songs').doc(songId).delete();
  }
}