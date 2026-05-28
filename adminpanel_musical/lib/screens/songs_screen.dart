import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGenreFilter = 'all';

  // Lista completa de géneros musicales
  final List<String> _genres = [
    'Rock', 'Pop', 'Hip Hop/Rap', 'Trap', 'Electrónica', 'Reggaetón',
    'Salsa', 'Merengue', 'Vallenato', 'Bachata', 'Jazz', 'Blues',
    'Clásica', 'Reggae', 'Metal', 'Indie', 'Folk', 'R&B', 'Country',
    'Alternativo', 'Música Andina', 'Bambuco', 'Pasillo', 'Dancehall',
    'Sanjuanero', 'Carranga', 'Música Popular', 'Despecho', 'Bolero',
    'Cumbia', 'Champeta', 'Fusión Andina', 'Latin Trap', 'Otro',
  ];

  void _deleteSong(String songId, String songTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '¿Eliminar canción?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "$songTitle"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteSong(songId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Canción "$songTitle" eliminada'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _getPlatformIcon(String platform) {
    switch (platform) {
      case 'youtube':
        return const Icon(Icons.video_library, color: Colors.red);
      case 'spotify':
        return const Icon(Icons.music_note, color: Color(0xFF1DB954));
      case 'deezer':
        return const Icon(Icons.audiotrack, color: Colors.blue);
      default:
        return const Icon(Icons.music_note, color: AppColors.primary);
    }
  }

  String _getPlatformName(String platform) {
    switch (platform) {
      case 'youtube':
        return 'YouTube';
      case 'spotify':
        return 'Spotify';
      case 'deezer':
        return 'Deezer';
      default:
        return platform;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Todas las Canciones',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getAllSongs(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.docs.length ?? 0;
                        return Text(
                          '$count canciones en total',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Filtros (búsqueda + género)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Campo de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o artista...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Dropdown de géneros
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _selectedGenreFilter,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Todos los géneros'),
                    ),
                    ..._genres.map((genre) => DropdownMenuItem(
                      value: genre,
                      child: Text(genre),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGenreFilter = value!;
                    });
                  },
                ),
              ),

            ],
          ),
        ),

        const SizedBox(height: 24),

        // Lista de canciones
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getAllSongs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final songs = snapshot.data?.docs ?? [];

              // Aplicar filtros
              final filteredSongs = songs.where((songDoc) {
                final song = songDoc.data() as Map<String, dynamic>;
                final title = song['title']?.toString().toLowerCase() ?? '';
                final artist =
                    song['artistName']?.toString().toLowerCase() ?? '';
                final genre = song['genre']?.toString() ?? '';

                // Filtro por búsqueda
                final matchesSearch = _searchQuery.isEmpty ||
                    title.contains(_searchQuery) ||
                    artist.contains(_searchQuery);

                // Filtro por género
                final matchesGenre = _selectedGenreFilter == 'all' ||
                    genre == _selectedGenreFilter;

                return matchesSearch && matchesGenre;
              }).toList();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: filteredSongs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_off,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron canciones',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final songDoc = filteredSongs[index];
                          final song = songDoc.data() as Map<String, dynamic>;

                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: index == filteredSongs.length - 1
                                      ? Colors.transparent
                                      : AppColors.surfaceLight,
                                ),
                              ),
                            ),
                            child: ListTile(
                              onTap: () => _showSongDetail(song, songDoc.id),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _getPlatformIcon(
                                    song['platform'] ?? 'youtube'),
                              ),
                              title: Text(
                                song['title'] ?? 'Sin título',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${song['artistName'] ?? 'Artista'} • ${song['genre'] ?? 'Género'}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.public,
                                        size: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getPlatformName(
                                            song['platform'] ?? 'youtube'),
                                        style: TextStyle(
                                          color: AppColors.textSecondary
                                              .withOpacity(0.7),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getFormattedDate(song['createdAt']),
                                        style: TextStyle(
                                          color: AppColors.textSecondary
                                              .withOpacity(0.7),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                ),
                                onPressed: () => _deleteSong(
                                    songDoc.id, song['title'] ?? 'Canción'),
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showSongDetail(Map<String, dynamic> song, String songId) {
    final status = song['status'] ?? 'approved';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          song['title'] ?? 'Canción',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('ID', songId),
              _detailRow('Título', song['title'] ?? '—'),
              _detailRow('Artista', song['artistName'] ?? '—'),
              _detailRow('Género', song['genre'] ?? '—'),
              _detailRow('Plataforma', song['platform'] ?? '—'),
              _detailRow('Estado', status == 'approved' ? 'Aprobada' : status == 'rejected' ? 'Rechazada' : 'Pendiente'),
              _detailRow('Subida', _getFormattedDate(song['createdAt'])),
              if (song['url'] != null)
                _detailRow('URL', song['url']),
              if (song['reviewMessage'] != null)
                _detailRow('Motivo', song['reviewMessage']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(dynamic timestamp) {
    if (timestamp == null) return 'Fecha desconocida';

    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Fecha desconocida';
      }

      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return 'Fecha desconocida';
    }
  }
}
