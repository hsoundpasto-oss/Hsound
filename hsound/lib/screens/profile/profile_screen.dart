import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hsound/services/firestore_service.dart';
import 'package:hsound/services/share_service.dart';
import 'package:hsound/models/event_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isArtist = false;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userProfile = await _firestoreService.getUserProfile();
      if (userProfile.exists) {
        final data = userProfile.data() as Map<String, dynamic>;
        setState(() {
          _userData = data;
          _isArtist = data['isArtist'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      _showErrorSnackBar('Error al cargar perfil: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🎯 MEJORADO: SnackBars con mejor contraste
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ✅ Función para eliminar canción
  Future<void> _deleteSong(String songId, String songTitle) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Eliminar Canción',
            style: TextStyle(color: Color(0xFF4ADE80)),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar "$songTitle"?\n\nEsta acción no se puede deshacer.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      try {
        await _firestoreService.deleteSong(songId);
        _showSuccessSnackBar('Cancion "$songTitle" eliminada');
      } catch (e) {
        _showErrorSnackBar('Error al eliminar: $e');
      }
    }
  }

  // Función para abrir enlaces sociales
  Future<void> _launchSocialUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('No se pudo abrir $url');
      }
    } catch (e) {
      _showErrorSnackBar('Error al abrir enlace: $e');
    }
  }

  // Función para compartir perfil
  void _shareProfile() async {
  try {
    final String artistName = _userData?['name'] ?? 'Artista';
    final String bio = _userData?['bio'] ?? '';
    
    await ShareService.shareArtistProfile(
      artistName: artistName,
      bio: bio,
    );
    _showSuccessSnackBar('Perfil compartido + App');
  } catch (e) {
    _showErrorSnackBar('Error al compartir: $e');
  }
}

  // 🎯 NUEVO: Función para contactar al equipo
  void _contactTeam() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Quieres ser Artista en HSound?',
            style: TextStyle(color: Color(0xFF4ADE80), fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Para garantizar la calidad de nuestro contenido, verificamos manualmente a todos los artistas que desean unirse a HSound.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Requisitos:',
                  style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildRequirementItem('- Ser artista activo en Pasto, Nariño'),
                _buildRequirementItem('- Tener musica original publicada'),
                _buildRequirementItem('- Contar con redes sociales activas'),
                _buildRequirementItem('- Comprometerse con la comunidad musical'),
                const SizedBox(height: 16),
                const Text(
                  'Contactanos:',
                  style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildContactItem('Email:', 'hsoundpasto@gmail.com'),
                _buildContactItem('Desarrollador:', 'soutesneydr / Esneydr Ibarra'),
                _buildContactItem('Desarrolladora:', 'sofiaburbanob_ / Sofia Burbano'),
                const SizedBox(height: 8),
                const Text(
                  'Envianos tu informacion y enlaces a tu musica para revisar tu perfil.',
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Entendido',
                style: TextStyle(color: Color(0xFF4ADE80)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchSocialUrl('mailto:hsoundpasto@gmail.com?subject=Solicitud%20de%20Artista%20HSound&body=Hola,%20me%20interesa%20ser%20artista%20en%20HSound.%20Mi%20nombre%20es:%20%0A%0ARedes%20sociales:%20%0AM%FAsica%20publicada:%20%0A%0A%21Gracias%21');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
                foregroundColor: const Color(0xFF1E1E1E),
              ),
              child: const Text('Enviar Email'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Color(0xFF4ADE80)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF4ADE80)),
            onPressed: _shareProfile,
            tooltip: 'Compartir perfil',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF4ADE80)),
            onPressed: () {
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)))
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: const Color(0xFF4ADE80),
              backgroundColor: const Color(0xFF1E1E1E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    _buildUserInfoCard(),
                    const SizedBox(height: 20),

                    if (_isArtist) _buildMotivationalMessages(),
                    if (_isArtist) const SizedBox(height: 20),

                    if (_isArtist && _hasSocialLinks())
                      _buildSocialLinksSection(),

                    const SizedBox(height: 20),

                    if (_isArtist) 
                      _buildArtistSongsSection(),

                    if (_isArtist) 
                      _buildArtistEventsSection(),

                    if (!_isArtist) 
                      _buildContactSection(),

                    if (_isArtist) 
                      _buildAddButtons(),

                    const SizedBox(height: 20),

                    _buildLogoutButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
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
          CircleAvatar(
            backgroundColor: const Color(0xFF4ADE80),
            radius: 40,
            child: user?.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user!.photoURL!,
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
          Text(
            _userData?['name'] ?? 'Usuario',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'No email',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (_isArtist)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ARTISTA VERIFICADO',
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_userData?['bio'] != null && _userData!['bio'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _userData!['bio'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          if (_isArtist && _userData?['musicalGenre'] != null && _userData!['musicalGenre'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Género: ${_userData!['musicalGenre']}',
                  style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          if (_isArtist && _userData?['instruments'] != null && (_userData!['instruments'] as List).isNotEmpty)
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
                    children: (_userData!['instruments'] as List).map((inst) {
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
    );
  }

  Widget _buildMotivationalMessages() {
    final messages = <Widget>[];
    final bool bioEmpty = _userData?['bio'] == null || _userData!['bio'].toString().trim().isEmpty;
    final bool noSocialLinks = !_hasSocialLinks();
    final bool noGenre = _userData?['musicalGenre'] == null || _userData!['musicalGenre'].toString().trim().isEmpty;

    if (bioEmpty) {
      messages.add(_buildMessageCard(
        icon: Icons.description,
        message: 'Completa tu biografía para que los fans te conozcan',
        buttonText: 'Editar Biografía',
        onTap: () => Navigator.pushNamed(context, '/edit_profile'),
      ));
    }

    if (noGenre) {
      messages.add(_buildMessageCard(
        icon: Icons.category,
        message: 'Completa tu género musical para que los fans te encuentren',
        buttonText: 'Agregar Género',
        onTap: () => Navigator.pushNamed(context, '/edit_profile'),
      ));
    }

    if (noSocialLinks) {
      messages.add(_buildMessageCard(
        icon: Icons.share,
        message: 'Agrega tus redes sociales para tener más alcance',
        buttonText: 'Agregar Redes',
        onTap: () => Navigator.pushNamed(context, '/edit_profile'),
      ));
    }

    return Column(
      children: messages,
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFA500).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA500).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFFA500), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    backgroundColor: const Color(0xFFFFA500).withOpacity(0.2),
                    foregroundColor: const Color(0xFFFFA500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_user,
            color: Color(0xFF4ADE80),
            size: 50,
          ),
          const SizedBox(height: 12),
          const Text(
            'Eres artista de Pasto?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Únete a HSound y comparte tu música con la comunidad',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Verificamos manualmente a cada artista para mantener la calidad de nuestro contenido musical.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _contactTeam,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ADE80),
              foregroundColor: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Solicitar Verificación'),
          ),

        ],
      ),
    );
  }

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
            'Sigueme en:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Enlaces de música
          if (_userData?['youtubeUrl'] != null &&
              _userData!['youtubeUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'youtube',
              label: 'YouTube',
              url: _userData!['youtubeUrl'],
            ),

          if (_userData?['spotifyUrl'] != null &&
              _userData!['spotifyUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'spotify',
              label: 'Spotify',
              url: _userData!['spotifyUrl'],
            ),

          if (_userData?['soundcloudUrl'] != null &&
              _userData!['soundcloudUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'soundcloud',
              label: 'SoundCloud',
              url: _userData!['soundcloudUrl'],
            ),

          if (_userData?['tiktokUrl'] != null &&
              _userData!['tiktokUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'tik-tok',
              label: 'TikTok',
              url: _userData!['tiktokUrl'],
            ),

          // Enlaces sociales
          if (_userData?['instagramUrl'] != null &&
              _userData!['instagramUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'instagram',
              label: 'Instagram',
              url: _userData!['instagramUrl'],
            ),

          if (_userData?['facebookUrl'] != null &&
              _userData!['facebookUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'facebook',
              label: 'Facebook',
              url: _userData!['facebookUrl'],
            ),

          // Enlaces de contacto
          if (_userData?['whatsappUrl'] != null &&
              _userData!['whatsappUrl'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'whatsapp',
              label: 'WhatsApp',
              url: _userData!['whatsappUrl'],
            ),

          if (_userData?['contactEmail'] != null &&
              _userData!['contactEmail'].toString().isNotEmpty)
            _buildSocialLinkItem(
              platform: 'gmail',
              label: 'Email de Contacto',
              url: 'mailto:${_userData!['contactEmail']}',
            ),
        ],
      ),
    );
  }

  Widget _buildArtistSongsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis Canciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getArtistSongs(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4ADE80)),
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFA500).withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.music_off, color: Color(0xFFFFA500), size: 50),
                    const SizedBox(height: 12),
                    const Text(
                      'Sube tu primera canción y empieza a sonar en Pasto',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _navigateToAddSong,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ADE80),
                        foregroundColor: const Color(0xFF1E1E1E),
                      ),
                      child: const Text('Subir Mi Primera Canción'),
                    ),
                  ],
                ),
              );
            }

            final songs = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final songDoc = songs[index];
                final songData = songDoc.data() as Map<String, dynamic>;

                return _buildSongItem(
                  songId: songDoc.id,
                  title: songData['title'] ?? 'Sin título',
                  genre: songData['genre'] ?? 'General',
                  platform: songData['platform'] ?? 'youtube',
                  status: songData['status'] ?? 'approved',
                  reviewMessage: songData['reviewMessage'],
                  onDelete: () => _deleteSong(
                      songDoc.id, songData['title'] ?? 'Canción'),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _navigateToAddSong,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF4ADE80),
              foregroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, size: 24),
            label: const Text(
              'Agregar Canción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _navigateToAddEvent,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFFFA500),
              foregroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.event, size: 24),
            label: const Text(
              'Agregar Evento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutConfirmation,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF4ADE80),
          foregroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout, color: Color(0xFF1E1E1E)),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ),
    );
  }

  //  Verificar si tiene enlaces sociales
  bool _hasSocialLinks() {
    return (_userData?['youtubeUrl'] != null &&
            _userData!['youtubeUrl'].toString().isNotEmpty) ||
        (_userData?['spotifyUrl'] != null &&
            _userData!['spotifyUrl'].toString().isNotEmpty) ||
        (_userData?['soundcloudUrl'] != null &&
            _userData!['soundcloudUrl'].toString().isNotEmpty) ||
        (_userData?['instagramUrl'] != null &&
            _userData!['instagramUrl'].toString().isNotEmpty);
  }

  //  Item de enlace social
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

  // Widget para mostrar cada canción con botón de eliminar
  Widget _buildSongItem({
    required String songId,
    required String title,
    required String genre,
    required String platform,
    required VoidCallback onDelete,
    String status = 'approved',
    String? reviewMessage,
  }) {
    Widget statusIcon;
    String statusText;
    Color statusColor;

    switch (status) {
      case 'pending':
        statusIcon = const Icon(Icons.access_time, color: Color(0xFFFFA500), size: 18);
        statusText = 'En revisión';
        statusColor = const Color(0xFFFFA500);
        break;
      case 'rejected':
        statusIcon = GestureDetector(
          onTap: () => _showRejectionReason(reviewMessage),
          child: const Icon(Icons.warning_amber, color: Colors.red, size: 18),
        );
        statusText = 'Rechazada';
        statusColor = Colors.red;
        break;
      default:
        statusIcon = const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 18);
        statusText = 'Aprobada';
        statusColor = const Color(0xFF4ADE80);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
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
                Row(
                  children: [
                    Text(
                      genre,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    statusIcon,
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón de eliminar
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            tooltip: 'Eliminar canción',
          ),
        ],
      ),
    );
  }

  void _showRejectionReason(String? reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Motivo de Rechazo',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          reason ?? 'No se especificó un motivo.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido', style: TextStyle(color: Color(0xFF4ADE80))),
          ),
        ],
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

  // Función para mostrar modal de cerrar sesión
  Future<void> _showLogoutConfirmation() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Color(0xFF4ADE80)),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
                foregroundColor: const Color(0xFF1E1E1E),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Función para navegar a agregar canción
  void _navigateToAddSong() {
    Navigator.pushNamed(context, '/add_song');
  }

  void _navigateToAddEvent() {
    Navigator.pushNamed(context, '/add_event');
  }

  Future<void> _deleteEvent(String eventId, String eventTitle) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Eliminar Evento',
            style: TextStyle(color: Color(0xFFFFA500)),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar "$eventTitle"?\n\nEsta acción no se puede deshacer.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      try {
        await _firestoreService.deleteEvent(eventId);
        _showSuccessSnackBar('Evento "$eventTitle" eliminado');
      } catch (e) {
        _showErrorSnackBar('Error al eliminar: $e');
      }
    }
  }

  Widget _buildArtistEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Mis Eventos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getArtistEvents(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4ADE80)),
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFA500).withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.event_busy, color: Color(0xFFFFA500), size: 50),
                    const SizedBox(height: 12),
                    const Text(
                      'No tienes eventos aún. ¡Crea tu primer evento!',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final events = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final eventDoc = events[index];
                final eventObj = Event.fromFirestore(eventDoc);

                final isExpired = eventObj.eventDate.isBefore(DateTime.now());

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isExpired
                          ? Colors.grey.withOpacity(0.3)
                          : const Color(0xFFFFA500).withOpacity(0.3),
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
                        child: const Icon(
                          Icons.event,
                          color: Color(0xFFFFA500),
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
                            Row(
                              children: [
                                Text(
                                  eventObj.venue,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  eventObj.price,
                                  style: const TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                                _buildStatusBadge(eventObj.status, reviewMessage: eventObj.reviewMessage),
                                const SizedBox(width: 8),
                                Text(
                                  '${eventObj.eventDate.day}/${eventObj.eventDate.month}/${eventObj.eventDate.year}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteEvent(eventDoc.id, eventObj.title),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Eliminar evento',
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, {String? reviewMessage}) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = const Color(0xFFFFA500);
        text = 'En revisión';
        icon = Icons.access_time;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rechazado';
        icon = Icons.warning_amber;
        break;
      default:
        color = const Color(0xFF4ADE80);
        text = 'Aprobado';
        icon = Icons.check_circle;
        break;
    }

    return GestureDetector(
      onTap: status == 'rejected'
          ? () => _showRejectionReason(reviewMessage)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
