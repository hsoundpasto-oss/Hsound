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

      // Obtener total de eventos y eventos pendientes
      final eventsSnapshot = await _firestore.collection('events').count().get();
      final totalEvents = eventsSnapshot.count;

      final pendingEventsSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      final pendingEvents = pendingEventsSnapshot.count;

      return {
        'totalUsers': totalUsers,
        'totalArtists': totalArtists,
        'totalSongs': totalSongs,
        'pendingApprovals': 0,
        'totalEvents': totalEvents,
        'pendingEvents': pendingEvents,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalUsers': 0,
        'totalArtists': 0, 
        'totalSongs': 0,
        'pendingApprovals': 0,
        'totalEvents': 0,
        'pendingEvents': 0,
      };
    }
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('name')
        .snapshots();
  }

  Stream<QuerySnapshot> getArtists() {
    return _firestore
        .collection('users')
        .where('isArtist', isEqualTo: true)
        .orderBy('name')
        .snapshots();
  }

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

  Future<QuerySnapshot> getSongsByArtist(String artistId) {
    return _firestore
        .collection('songs')
        .where('artistId', isEqualTo: artistId)
        .get();
  }

  Future<QuerySnapshot> getEventsByArtist(String artistId) {
    return _firestore
        .collection('events')
        .where('artistId', isEqualTo: artistId)
        .get();
  }

  // Actualizar rol de usuario
  Future<void> updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'role': newRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> makeUserArtist(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'isArtist': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeArtistRole(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'isArtist': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Eliminar usuario
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Eliminar canción
  Future<void> deleteSong(String songId) async {
    await _firestore.collection('songs').doc(songId).delete();
  }

  // Obtener canciones pendientes de revisión
  Stream<QuerySnapshot> getPendingSongs() {
    return _firestore
        .collection('songs')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obtener canciones por estado
  Stream<QuerySnapshot> getSongsByStatus(String status) {
    if (status == 'all') {
      return getAllSongs();
    }
    return _firestore
        .collection('songs')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Aprobar canción
  Future<void> approveSong(String songId, String adminUid) async {
    await _firestore.collection('songs').doc(songId).update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminUid,
    });
  }

  // Rechazar canción con motivo
  Future<void> rejectSong(String songId, String reason, String adminUid) async {
    await _firestore.collection('songs').doc(songId).update({
      'status': 'rejected',
      'reviewMessage': reason,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminUid,
    });
  }

  // ========================================
  // MÉTODOS PARA EVENTOS
  // ========================================

  Stream<QuerySnapshot> getAllEvents() {
    return _firestore
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getEventsByStatus(String status) {
    if (status == 'all') {
      return getAllEvents();
    }
    return _firestore
        .collection('events')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> approveEvent(String eventId, String adminUid) async {
    await _firestore.collection('events').doc(eventId).update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminUid,
    });
  }

  Future<void> rejectEvent(String eventId, String reason, String adminUid) async {
    await _firestore.collection('events').doc(eventId).update({
      'status': 'rejected',
      'reviewMessage': reason,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminUid,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  Future<void> createEvent({
    required String artistId,
    required String artistName,
    required String title,
    String? description,
    required String venue,
    required String address,
    String? googleMapsUrl,
    required DateTime eventDate,
    required String price,
  }) async {
    await _firestore.collection('events').add({
      'artistId': artistId,
      'artistName': artistName,
      'title': title,
      'description': description,
      'venue': venue,
      'address': address,
      'googleMapsUrl': googleMapsUrl,
      'eventDate': Timestamp.fromDate(eventDate),
      'price': price,
      'status': 'approved',
      'createdAt': FieldValue.serverTimestamp(),
      'reviewMessage': null,
      'reviewedBy': null,
      'reviewedAt': null,
    });
  }
}