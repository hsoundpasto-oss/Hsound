import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hsound/services/share_service.dart';
import 'package:hsound/services/firestore_service.dart';
import 'package:hsound/screens/search/search_screen.dart';
import 'package:hsound/screens/favorites/favorites_screen.dart';
import 'package:hsound/screens/profile/profile_screen.dart';
import 'package:hsound/models/event_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;
  String _displayName = '';
  String? _photoUrl;
  bool _showAllSongs = false;
  bool _showAllEvents = false;

  final List<Widget> _pages = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializePages();
  }

  void _initializePages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _pages.addAll([
          const SearchScreen(),
          const FavoritesScreen(),
          const ProfileScreen(),
        ]);
        _isInitialized = true;
      });
    });
  }

  void _loadUserData() async {
    if (user != null) {
      // Fallback inmediato con email
      setState(() => _displayName = user!.email ?? 'Usuario');
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get()
            .timeout(const Duration(seconds: 3));
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final name = data['name']?.toString();
          if (name != null && name.isNotEmpty) {
            setState(() => _displayName = name);
          }
          final photo = data['photoUrl']?.toString();
          if (photo != null && photo.isNotEmpty) {
            setState(() => _photoUrl = photo);
          }
        }
      } catch (_) {}
    }
  }

  // 🎯 Alertas mejoradas
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF2D2D2D),
                  backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                  child: _photoUrl == null
                      ? const Icon(Icons.person, color: Color(0xFF4ADE80), size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Disfruta de la música',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contenido de canciones
          _buildSongsSection(),

          const SizedBox(height: 24),

          // Contenido de eventos
          _buildEventsSection(),
        ],
      ),
    );
  }

  Widget _buildSongsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getApprovedSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4ADE80)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Canciones Recientes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Aún no hay canciones. ¡Sé el primero en subir una!',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        }

        final songs = snapshot.data!.docs;
        final displaySongs = _showAllSongs || songs.length <= 6 ? songs : songs.sublist(0, 6);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Canciones Recientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${songs.length} canciones disponibles',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displaySongs.length,
              itemBuilder: (context, index) {
                final song = displaySongs[index];
                final data = song.data() as Map<String, dynamic>;

                return _buildSongItem(
                  songId: song.id,
                  title: data['title'] ?? 'Sin título',
                  artist: data['artistName'] ?? 'Artista desconocido',
                  genre: data['genre'] ?? 'General',
                  platform: data['platform'] ?? 'youtube',
                  likes: data['likes'] ?? 0,
                  createdAt: data['createdAt'],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/song_player',
                      arguments: {
                        'url': data['url'],
                        'title': data['title'],
                        'artist': data['artistName'],
                        'platform': data['platform'],
                        'artistId': data['artistId'] ?? '',
                      },
                    );
                  },
                );
              },
            ),
            if (songs.length > 6) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _showAllSongs = !_showAllSongs);
                  },
                  icon: Icon(
                    _showAllSongs ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF4ADE80),
                    size: 20,
                  ),
                  label: Text(
                    _showAllSongs
                        ? 'Mostrar menos'
                        : 'Ver todas (${songs.length})',
                    style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEventsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getApprovedEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final events = snapshot.data!.docs;
        final displayEvents = _showAllEvents || events.length <= 2 ? events : events.sublist(0, 2);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Eventos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${events.length} eventos',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayEvents.length,
              itemBuilder: (context, index) {
                final eventDoc = displayEvents[index];
                final eventObj = Event.fromFirestore(eventDoc);
                final isExpired = eventObj.eventDate.isBefore(DateTime.now());

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/event_detail',
                      arguments: {'eventId': eventDoc.id},
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isExpired
                            ? Colors.grey.withOpacity(0.3)
                            : const Color(0xFF4ADE80).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isExpired ? Icons.event_busy : Icons.event_note,
                            color: isExpired ? Colors.grey : const Color(0xFF4ADE80),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      eventObj.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isExpired)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Expirado',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${eventObj.artistName} • ${eventObj.venue}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${eventObj.price} • ${eventObj.eventDate.day}/${eventObj.eventDate.month}/${eventObj.eventDate.year}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF4ADE80),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (events.length > 2) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _showAllEvents = !_showAllEvents);
                  },
                  icon: Icon(
                    _showAllEvents ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF4ADE80),
                    size: 20,
                  ),
                  label: Text(
                    _showAllEvents
                        ? 'Mostrar menos'
                        : 'Ver más (${events.length})',
                    style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'HSOUND',
          style: TextStyle(
            color: Color(0xFF4ADE80),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isInitialized
          ? _selectedIndex == 0
              ? _buildHomeContent()
              : _pages[_selectedIndex - 1]
          : const Center(
              child: CircularProgressIndicator(color: Color(0xFF4ADE80)),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: const Color(0xFF4ADE80),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return 'Hoy';
      if (diff.inDays == 1) return 'Ayer';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
      if (diff.inDays < 30) return 'Hace ${(diff.inDays / 7).floor()} sem';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildSongItem({
    required String songId,
    required String title,
    required String artist,
    required String genre,
    required String platform,
    required int likes,
    required dynamic createdAt,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D2D2D)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: _getPlatformIcon(platform)),
            ),
            const SizedBox(width: 14),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        artist,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(color: Colors.grey[700], fontSize: 11),
                  ),
                ],
              ),
            ),
            
            StreamBuilder<DocumentSnapshot>(
              stream: _firestoreService.getSongLikesStream(songId),
              builder: (context, snapshot) {
                final currentLikes = (snapshot.data?.data() as Map<String, dynamic>?)?['likes'] ?? likes;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$currentLikes', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 1),
                    StreamBuilder<bool>(
                      stream: Stream.fromFuture(_firestoreService.isSongLiked(songId)),
                      builder: (context, snap) {
                        final isLiked = snap.data ?? false;
                        return GestureDetector(
                          onTap: () async {
                            try {
                              await _firestoreService.toggleLike(songId);
                              _showSuccessSnackBar(isLiked ? 'Removido de favoritos' : 'Agregado a favoritos');
                            } catch (e) {
                              _showErrorSnackBar('Error: $e');
                            }
                          },
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            
            GestureDetector(
              onTap: () => _shareSong(title, artist),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: const Icon(Icons.share, color: Color(0xFF4ADE80), size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareSong(String title, String artist) async {
  try {
    await ShareService.shareSong(
      songTitle: title,
      artistName: artist,
    );
    _showSuccessSnackBar('Cancion compartida + App');
  } catch (e) {
    _showErrorSnackBar('Error al compartir: $e');
  }
}

  Widget _getPlatformIcon(String platform) {
    switch (platform) {
      case 'youtube':
        return Image.asset('assets/images/youtube.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.video_library, color: Colors.red, size: 16));
      case 'spotify':
        return Image.asset('assets/images/spotify.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.music_note, color: Color(0xFF1DB954), size: 16));
      case 'soundcloud':
        return Image.asset('assets/images/soundcloud.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.cloud, color: Color(0xFFFF7700), size: 16));
      case 'youtube_music':
        return Image.asset('assets/images/youtube.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.library_music, color: Colors.red, size: 16));
      default:
        return const Icon(Icons.music_note, color: Color(0xFF4ADE80), size: 16);
    }
  }
}