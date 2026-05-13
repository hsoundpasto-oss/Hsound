import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late FirestoreService _firestoreService;
  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'totalArtists': 0,
    'totalSongs': 0,
  };

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _firestoreService.getDashboardStats();
    setState(() {
      _stats = stats;
    });
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Hace un momento';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      dateTime = DateTime.parse(timestamp);
    } else {
      return 'Hace un momento';
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(Map<String, dynamic> song) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPlatformIcon(song['platform'] ?? 'youtube'),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song['title'] ?? 'Sin título',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${song['artistName'] ?? 'Artista'} • ${song['genre'] ?? 'Género'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'youtube':
        return Icons.video_library;
      case 'spotify':
        return Icons.music_note;
      case 'deezer':
        return Icons.audiotrack;
      default:
        return Icons.music_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Resumen general de HSound',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Estadísticas principales
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  // Total de usuarios
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 48) / 4
                        : (constraints.maxWidth - 16) / 2,
                    child: StatCard(
                      title: 'Total Usuarios',
                      value: _stats['totalUsers'].toString(),
                      icon: Icons.people,
                      color: AppColors.info,
                    ),
                  ),
                  // Artistas
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 48) / 4
                        : (constraints.maxWidth - 16) / 2,
                    child: StatCard(
                      title: 'Artistas',
                      value: _stats['totalArtists'].toString(),
                      icon: Icons.person_outline,
                      color: AppColors.success,
                    ),
                  ),
                  // Canciones
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 48) / 4
                        : (constraints.maxWidth - 16) / 2,
                    child: StatCard(
                      title: 'Canciones',
                      value: _stats['totalSongs'].toString(),
                      icon: Icons.library_music,
                      color: AppColors.primary,
                    ),
                  ),
                  // 🎵 Género Popular
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 48) / 4
                        : (constraints.maxWidth - 16) / 2,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getAllSongs(),
                      builder: (context, snapshot) {
                        int popularGenreCount = 0;
                        String popularGenre = 'N/A';

                        if (snapshot.hasData) {
                          final songs = snapshot.data!.docs;
                          final genreCount = <String, int>{};

                          for (final doc in songs) {
                            final song = doc.data() as Map<String, dynamic>;
                            final genre = song['genre'] ?? 'Otro';
                            genreCount[genre] = (genreCount[genre] ?? 0) + 1;
                          }

                          if (genreCount.isNotEmpty) {
                            final entry = genreCount.entries.reduce(
                              (a, b) => a.value > b.value ? a : b,
                            );
                            popularGenre = entry.key;
                            popularGenreCount = entry.value;
                          }
                        }

                        return StatCard(
                          title: 'Género Popular',
                          value: popularGenre,
                          icon: Icons.trending_up,
                          color: AppColors.warning,
                          trend: popularGenreCount > 0
                              ? '$popularGenreCount canciones'
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Usuarios recientes
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuarios Recientes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getRecentUsers(limit: 5),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final users = snapshot.data?.docs ?? [];

                    if (users.isEmpty) {
                      return const Text('No hay usuarios registrados');
                    }

                    return Column(
                      children: users.map((doc) {
                        final user = doc.data() as Map<String, dynamic>;
                        final userType = user['isArtist'] == true
                            ? 'Artista'
                            : 'Usuario';

                        return _buildActivityItem(
                          icon: Icons.person_add,
                          title: 'Nuevo $userType',
                          subtitle: '${user['name']} - ${user['email']}',
                          time: _getTimeAgo(user['createdAt']),
                          color: AppColors.success,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Canciones recientes
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Canciones Recientes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getRecentSongs(limit: 3),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final songs = snapshot.data?.docs ?? [];

                    if (songs.isEmpty) {
                      return const Text('No hay canciones recientes');
                    }

                    return Column(
                      children: songs.map((doc) {
                        final song = doc.data() as Map<String, dynamic>;
                        return _buildSongItem(song);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
