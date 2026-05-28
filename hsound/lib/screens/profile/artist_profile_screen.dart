import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/event_model.dart';
import '../../services/share_service.dart';

class ArtistProfileScreen extends StatefulWidget {
  final String artistId;

  const ArtistProfileScreen({super.key, required this.artistId});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  Map<String, dynamic>? _artistData;
  bool _isLoading = true;
  List<QueryDocumentSnapshot> _artistSongs = [];
  List<QueryDocumentSnapshot> _artistEvents = [];

  @override
  void initState() {
    super.initState();
    _loadArtistData();
    _loadArtistSongs();
    _loadArtistEvents();
  }

  Future<void> _loadArtistData() async {
    try {
      final artistDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.artistId)
          .get();

      if (artistDoc.exists) {
        setState(() {
          _artistData = artistDoc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading artist profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadArtistSongs() async {
    try {
      print('🎵 Cargando canciones para artista: ${widget.artistId}');

      final songsQuery = await FirebaseFirestore.instance
          .collection('songs')
          .where('artistId', isEqualTo: widget.artistId)
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .get();

      print('🎵 Canciones encontradas: ${songsQuery.docs.length}');

      // 🎯 DEBUG: Ver información de las canciones
      for (final doc in songsQuery.docs) {
        final data = doc.data();
        print('🎵 Canción: ${data['title']} - artistId: ${data['artistId']}');
      }

      setState(() {
        _artistSongs = songsQuery.docs;
      });
    } catch (e) {
      print('❌ Error cargando canciones del artista: $e');
    }
  }

  Future<void> _loadArtistEvents() async {
    try {
      final eventsQuery = await FirebaseFirestore.instance
          .collection('events')
          .where('artistId', isEqualTo: widget.artistId)
          .where('status', isEqualTo: 'approved')
          .orderBy('eventDate', descending: false)
          .get();

      setState(() {
        _artistEvents = eventsQuery.docs;
      });
    } catch (e) {
      print('❌ Error cargando eventos del artista: $e');
    }
  }

  // Función para abrir enlaces sociales
  Future<void> _launchSocialUrl(String url) async {
    try {
      String normalized = url.trim();
      if (normalized.isEmpty) return;
      if (!normalized.startsWith('http://') && !normalized.startsWith('https://') && !normalized.startsWith('mailto:')) {
        normalized = 'https://$normalized';
      }
      final Uri uri = Uri.parse(normalized);
      if (!uri.isAbsolute || (uri.scheme != 'http' && uri.scheme != 'https' && uri.scheme != 'mailto')) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Enlace no válido'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      if (!await canLaunchUrl(uri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('No hay una aplicación instalada para abrir este enlace'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('No se pudo abrir el enlace'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Función para compartir perfil del artista
  void _shareArtistProfile() async {
    try {
      final String artistName = _artistData?['name'] ?? 'Artista';
      final String bio = _artistData?['bio'] ?? '';

      await ShareService.shareArtistProfile(
        artistName: artistName,
        bio: bio,
        // 🎯 ELIMINADO: profileUrl (ya no se necesita)
      );

      // 🎯 MENSAJE MEJORADO
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Perfil compartido + App',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF15803D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al compartir: $e',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Color(0xFF4ADE80)),
        title: const Text(
          'Perfil del Artista',
          style: TextStyle(color: Color(0xFF4ADE80)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF4ADE80)),
            onPressed: _shareArtistProfile,
            tooltip: 'Compartir perfil',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4ADE80)))
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF4ADE80),
              backgroundColor: const Color(0xFF1E1E1E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          backgroundColor: const Color(0xFF4ADE80),
                          radius: 40,
                          child: _artistData?['photoUrl'] != null
                              ? ClipOval(
                                  child: Image.network(
                                    _artistData!['photoUrl']!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Color(0xFF1E1E1E),
                                  size: 40,
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Nombre
                        Text(
                          _artistData?['name'] ?? 'Artista',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email
                        if (_artistData?['email'] != null)
                          Text(
                            _artistData!['email'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 8),

                        // Badge de artista
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80),
                            borderRadius: BorderRadius.circular(20),
                          ),
            child: const Text(
              'Sigueme en:',
              style: TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Biografía
                        if (_artistData?['bio'] != null &&
                            _artistData!['bio'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _artistData!['bio'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Género musical
                        if (_artistData?['musicalGenre'] != null && _artistData!['musicalGenre'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Género: ${_artistData!['musicalGenre']}',
                                style: const TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        // Instrumentos
                        if (_artistData?['instruments'] != null && (_artistData!['instruments'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              children: [
                                const Text(
                                  'Instrumentos:',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: (_artistData!['instruments'] as List).map((inst) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2D2D2D),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        inst.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 11),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sección de enlaces sociales
                  if (_hasSocialLinks()) _buildSocialLinksSection(),

                  const SizedBox(height: 20),

                  // Sección de Canciones del Artista
                  const Text(
                    'Canciones del Artista',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_artistSongs.isEmpty)
                    _buildEmptySongsState()
                  else
                    _buildArtistSongsList(),

                  const SizedBox(height: 24),

                  // Sección de Eventos del Artista
                  const Text(
                    'Eventos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_artistEvents.isEmpty)
                    _buildEmptyEventsState()
                  else
                    _buildArtistEventsList(),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadArtistData(),
      _loadArtistSongs(),
      _loadArtistEvents(),
    ]);
  }

  Widget _buildEmptySongsState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.music_off, color: Colors.grey, size: 50),
          const SizedBox(height: 12),
          Text(
            '${_artistData?['name'] ?? 'Este artista'} aún no ha subido canciones',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy, color: Colors.grey, size: 50),
          const SizedBox(height: 12),
          Text(
            '${_artistData?['name'] ?? 'Este artista'} aún no tiene eventos',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArtistEventsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _artistEvents.length,
      itemBuilder: (context, index) {
        final eventDoc = _artistEvents[index];
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
            padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isExpired ? Icons.event_busy : Icons.event,
                    color: isExpired ? Colors.grey : const Color(0xFF4ADE80),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
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
                              maxLines: 2,
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
                      const SizedBox(height: 4),
                      Text(
                        '${eventObj.venue} • ${eventObj.price}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${eventObj.eventDate.day}/${eventObj.eventDate.month}/${eventObj.eventDate.year}',
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
    );
  }

  Widget _buildArtistSongsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _artistSongs.length,
      itemBuilder: (context, index) {
        final songDoc = _artistSongs[index];
        final songData = songDoc.data() as Map<String, dynamic>;

        return _buildSongItem(
          title: songData['title'] ?? 'Sin título',
          artist: songData['artistName'] ?? 'Artista desconocido',
          genre: songData['genre'] ?? 'General',
          platform: songData['platform'] ?? 'youtube',
          songUrl: songData['url'] ?? '',
        );
      },
    );
  }

  Widget _buildSongItem({
    required String title,
    required String artist,
    required String genre,
    required String platform,
    required String songUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/song_player',
          arguments: {
            'url': songUrl,
            'title': title,
            'artist': artist,
            'platform': platform,
            'artistId': widget.artistId,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Icono de plataforma
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _getPlatformIcon(platform),
            ),
            const SizedBox(width: 16),

            // Información de la canción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$artist • $genre',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Botón de play
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/song_player',
                  arguments: {
                    'url': songUrl,
                    'title': title,
                    'artist': artist,
                    'platform': platform,
                    'artistId': widget.artistId,
                  },
                );
              },
              icon: const Icon(
                Icons.play_arrow,
                color: Color(0xFF4ADE80),
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Verificar si tiene enlaces sociales
  bool _hasSocialLinks() {
    return (_artistData?['youtubeUrl'] != null &&
            _artistData!['youtubeUrl'].toString().isNotEmpty) ||
        (_artistData?['spotifyUrl'] != null &&
            _artistData!['spotifyUrl'].toString().isNotEmpty) ||
        (_artistData?['instagramUrl'] != null &&
            _artistData!['instagramUrl'].toString().isNotEmpty);
  }

  // Sección de enlaces sociales
// Reemplaza la función _buildSocialLinksSection con esta:
  Widget _buildSocialLinksSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📱 Sígueme en:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 🎯 TODAS LAS REDES SOCIALES - Agrega las que faltan
          if (_artistData?['youtubeUrl'] != null &&
              _artistData!['youtubeUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'youtube',
              label: 'YouTube',
              url: _artistData!['youtubeUrl'],
            ),

          if (_artistData?['spotifyUrl'] != null &&
              _artistData!['spotifyUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'spotify',
              label: 'Spotify',
              url: _artistData!['spotifyUrl'],
            ),

          if (_artistData?['soundcloudUrl'] != null &&
              _artistData!['soundcloudUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'soundcloud',
              label: 'SoundCloud',
              url: _artistData!['soundcloudUrl'],
            ),

          if (_artistData?['tiktokUrl'] != null &&
              _artistData!['tiktokUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'tik-tok',
              label: 'TikTok',
              url: _artistData!['tiktokUrl'],
            ),

          if (_artistData?['instagramUrl'] != null &&
              _artistData!['instagramUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'instagram',
              label: 'Instagram',
              url: _artistData!['instagramUrl'],
            ),

          if (_artistData?['facebookUrl'] != null &&
              _artistData!['facebookUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'facebook',
              label: 'Facebook',
              url: _artistData!['facebookUrl'],
            ),

          if (_artistData?['whatsappUrl'] != null &&
              _artistData!['whatsappUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'whatsapp',
              label: 'WhatsApp',
              url: _artistData!['whatsappUrl'],
            ),

          if (_artistData?['contactEmail'] != null &&
              _artistData!['contactEmail'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'gmail',
              label: 'Email de Contacto',
              url: 'mailto:${_artistData!['contactEmail']}',
            ),
        ],
      ),
    );
  }

  // Item de enlace social
  Widget _buildSocialLinkItem({
    required String platform,
    required String label,
    required String url,
  }) {
    final color = _socialColor(platform);
    return GestureDetector(
      onTap: () => _launchSocialUrl(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/$platform.png', width: 24, height: 24,
              errorBuilder: (c, e, s) => Icon(Icons.link, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _socialColor(String platform) {
    switch (platform) {
      case 'youtube': return Colors.red;
      case 'spotify': return const Color(0xFF1DB954);
      case 'soundcloud': return const Color(0xFFFF7700);
      case 'tik-tok': return const Color(0xFF000000);
      case 'instagram': return const Color(0xFFE4405F);
      case 'facebook': return const Color(0xFF1877F2);
      case 'whatsapp': return const Color(0xFF25D366);
      case 'gmail': return const Color(0xFFEA4335);
      default: return Colors.grey;
    }
  }

  // Iconos por plataforma
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
