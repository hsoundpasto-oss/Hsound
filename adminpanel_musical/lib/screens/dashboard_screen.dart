import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  final Function(String)? onNavigate;
  const DashboardScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late FirestoreService _firestoreService;
  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'totalArtists': 0,
    'totalSongs': 0,
    'totalGenres': 0,
    'totalEvents': 0,
    'pendingEvents': 0,
  };
  String? _selectedSection;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _firestoreService.getDashboardStats();
    final allSongs = await FirebaseFirestore.instance.collection('songs').get();
    final uniqueGenres = allSongs.docs
        .map((doc) => (doc.data()['genre'] ?? 'Otro') as String)
        .toSet()
        .length;
    setState(() {
      _stats = stats;
      _stats['totalGenres'] = uniqueGenres;
    });
  }

  String _getFormattedDate(dynamic timestamp) {
    if (timestamp == null) return '—';
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return '—';
      }
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return '—';
    }
  }

  Color _getRoleColor(bool isArtist) {
    return isArtist ? AppColors.roleMusician : AppColors.roleUser;
  }

  String _getRoleLabel(bool isArtist) {
    return isArtist ? 'Artista' : 'Usuario';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return AppColors.success;
      case 'pending': return AppColors.warning;
      case 'rejected': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved': return 'Aprobada';
      case 'pending': return 'Pendiente';
      case 'rejected': return 'Rechazada';
      default: return '—';
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'youtube': return Icons.video_library;
      case 'spotify': return Icons.music_note;
      case 'deezer': return Icons.audiotrack;
      default: return Icons.music_note;
    }
  }

  void _deleteSong(String songId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar canción', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('¿Eliminar "$title"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteSong(songId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String userId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar usuario', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('¿Eliminar "$name"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteUser(userId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
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
            style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Resumen general de HSound',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Stat cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 64) / 5 : (constraints.maxWidth - 16) / 2,
                    child: StatCard(
                      title: 'Total Usuarios',
                      value: _stats['totalUsers'].toString(),
                      icon: Icons.people,
                      color: AppColors.info,
                      isSelected: _selectedSection == 'users',
                      onTap: () => setState(() => _selectedSection = 'users'),
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 64) / 5 : (constraints.maxWidth - 16) / 2,
                    child: StatCard(
                      title: 'Artistas',
                      value: _stats['totalArtists'].toString(),
                      icon: Icons.person,
                      color: AppColors.success,
                      isSelected: _selectedSection == 'artists',
                      onTap: () => setState(() => _selectedSection = 'artists'),
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 64) / 5 : (constraints.maxWidth - 16) / 2,
                    child: StatCard(
                      title: 'Canciones',
                      value: _stats['totalSongs'].toString(),
                      icon: Icons.library_music,
                      color: AppColors.warning,
                      isSelected: _selectedSection == 'songs',
                      onTap: () => setState(() => _selectedSection = 'songs'),
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 64) / 5 : (constraints.maxWidth - 16) / 2,
                    child: StatCard(
                      title: 'Géneros',
                      value: _stats['totalGenres'].toString(),
                      icon: Icons.disc_full,
                      color: AppColors.roleMusician,
                      isSelected: _selectedSection == 'genres',
                      onTap: () => setState(() => _selectedSection = 'genres'),
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 64) / 5 : (constraints.maxWidth - 16) / 2,
                    child: StatCard(
                      title: 'Eventos',
                      value: _stats['totalEvents'].toString(),
                      icon: Icons.event_note,
                      color: const Color(0xFF4ADE80),
                      isSelected: _selectedSection == 'events',
                      onTap: () => setState(() => _selectedSection = 'events'),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Content section based on selection
          if (_selectedSection != null) _buildContentSection(),
          if (_selectedSection == null)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.touch_app, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'Selecciona una tarjeta para ver los detalles',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    switch (_selectedSection) {
      case 'users': return _buildUsersContent();
      case 'artists': return _buildArtistsContent();
      case 'songs': return _buildSongsContent();
      case 'genres': return _buildGenresContent();
      case 'events': return _buildEventsContent();
      default: return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────
  // USERS
  // ─────────────────────────────────────────────
  Widget _buildUsersContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
        }
        final users = snapshot.data?.docs ?? [];
        final artistsCount = users.where((d) => (d.data() as Map)['isArtist'] == true).length;
        final normalCount = users.length - artistsCount;

        return Column(
          children: [
            // Table
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Todos los Usuarios',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('${users.length} registrados', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (users.isEmpty)
                    const Center(child: Text('No hay usuarios', style: TextStyle(color: AppColors.textSecondary)))
                  else
                    ...users.map((doc) {
                      final user = doc.data() as Map<String, dynamic>;
                      final isArtist = user['isArtist'] == true;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.surfaceLight)),
                        ),
                        child: ListTile(
                          onTap: () => _showUserDetail(user, doc.id, isArtist),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: _getRoleColor(isArtist).withOpacity(0.2),
                            backgroundImage: user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty
                                ? NetworkImage(user['photoUrl'])
                                : null,
                            child: user['photoUrl'] == null || user['photoUrl'].toString().isEmpty
                                ? Text(
                                    (user['name']?[0] ?? 'U').toString().toUpperCase(),
                                    style: TextStyle(color: _getRoleColor(isArtist), fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          title: Text(user['name'] ?? 'Usuario', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          subtitle: Text('${user['email'] ?? '—'} • ${_getFormattedDate(user['createdAt'])}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(isArtist).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getRoleLabel(isArtist),
                                  style: TextStyle(color: _getRoleColor(isArtist), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                                tooltip: 'Eliminar usuario',
                                onPressed: () => _deleteUser(doc.id, user['name'] ?? 'Usuario'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Chart: Artists vs Normal Users
            _buildUserRoleChart(artistsCount, normalCount),
          ],
        );
      },
    );
  }

  Widget _buildUserRoleChart(int artists, int normal) {
    final total = artists + normal;
    if (total == 0) return const SizedBox.shrink();
    return Container(
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
            'Usuarios: Artistas vs Normales',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: artists.toDouble(),
                          color: AppColors.roleMusician,
                          title: '${(artists / total * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: normal.toDouble(),
                          color: AppColors.roleUser,
                          title: '${(normal / total * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          radius: 50,
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(AppColors.roleMusician, 'Artistas', artists.toString()),
                    const SizedBox(height: 8),
                    _legendItem(AppColors.roleUser, 'Usuarios', normal.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ARTISTS
  // ─────────────────────────────────────────────
  Widget _buildArtistsContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
        }
        final allUsers = snapshot.data?.docs ?? [];
        final artists = allUsers.where((d) => (d.data() as Map)['isArtist'] == true).toList();
        final normalCount = allUsers.length - artists.length;

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Todos los Artistas',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('${artists.length} artistas', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (artists.isEmpty)
                    const Center(child: Text('No hay artistas', style: TextStyle(color: AppColors.textSecondary)))
                  else
                    ...artists.map((doc) {
                      final user = doc.data() as Map<String, dynamic>;
                      final genre = user['musicalGenre'] as String?;
                      final instruments = user['instruments'] as List?;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.surfaceLight)),
                        ),
                        child: ListTile(
                          onTap: () => _showUserDetail(user, doc.id, true),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.roleMusician.withOpacity(0.2),
                            backgroundImage: user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty
                                ? NetworkImage(user['photoUrl'])
                                : null,
                            child: user['photoUrl'] == null || user['photoUrl'].toString().isEmpty
                                ? Text(
                                    (user['name']?[0] ?? 'A').toString().toUpperCase(),
                                    style: const TextStyle(color: AppColors.roleMusician, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          title: Text(user['name'] ?? 'Artista', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email'] ?? '—', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              if (genre != null)
                                Text('Género: $genre', style: const TextStyle(color: AppColors.primary, fontSize: 11)),
                              if (instruments != null && instruments.isNotEmpty)
                                Text('Instrumentos: ${instruments.join(', ')}', style: const TextStyle(color: AppColors.warning, fontSize: 11)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.person_off, size: 18, color: AppColors.warning),
                                tooltip: 'Quitar rol artista',
                                onPressed: () => _firestoreService.removeArtistRole(doc.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                                tooltip: 'Eliminar artista',
                                onPressed: () => _deleteUser(doc.id, user['name'] ?? 'Artista'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildUserRoleChart(artists.length, normalCount),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // SONGS
  // ─────────────────────────────────────────────
  Widget _buildSongsContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
        }
        final songs = snapshot.data?.docs ?? [];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceLight),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Todas las Canciones',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('${songs.length} canciones', style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
              if (songs.isEmpty)
                const Center(child: Text('No hay canciones', style: TextStyle(color: AppColors.textSecondary)))
              else
                ...songs.map((doc) {
                  final song = doc.data() as Map<String, dynamic>;
                  final status = song['status'] ?? 'approved';
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.surfaceLight)),
                    ),
                    child: ListTile(
                      onTap: () => _showSongDetail(song, doc.id),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getPlatformIcon(song['platform'] ?? ''), color: AppColors.primary, size: 20),
                      ),
                      title: Text(song['title'] ?? 'Sin título', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${song['artistName'] ?? '—'} • ${song['genre'] ?? '—'}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                            tooltip: 'Eliminar canción',
                            onPressed: () => _deleteSong(doc.id, song['title'] ?? 'Canción'),
                          ),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // GENRES
  // ─────────────────────────────────────────────
  Widget _buildGenresContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
        }
        final songs = snapshot.data?.docs ?? [];

        // Count songs per genre
        final genreCount = <String, int>{};
        for (final doc in songs) {
          final s = doc.data() as Map<String, dynamic>;
          final genre = s['genre'] ?? 'Otro';
          genreCount[genre] = (genreCount[genre] ?? 0) + 1;
        }

        final sortedGenres = genreCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final colors = [
          AppColors.primary, AppColors.success, AppColors.warning,
          AppColors.error, AppColors.info, AppColors.secondary,
          AppColors.roleMusician, AppColors.roleUser,
        ];

        return Column(
          children: [
            // Table
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Géneros Musicales',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('${sortedGenres.length} géneros', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (sortedGenres.isEmpty)
                    const Center(child: Text('No hay géneros', style: TextStyle(color: AppColors.textSecondary)))
                  else
                    ...sortedGenres.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final genre = entry.value.key;
                      final count = entry.value.value;
                      final total = songs.length;
                      final pct = total > 0 ? (count / total * 100) : 0.0;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.surfaceLight)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: colors[idx % colors.length].withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text('${idx + 1}', style: TextStyle(color: colors[idx % colors.length], fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(genre, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                            ),
                            Text('$count canciones', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 80,
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                backgroundColor: AppColors.background,
                                color: colors[idx % colors.length],
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${pct.toStringAsFixed(0)}%',
                                style: TextStyle(color: colors[idx % colors.length], fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Chart: genre distribution
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
                    'Distribución de Géneros',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: sortedGenres.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final count = entry.value.value;
                          final total = songs.length;
                          return PieChartSectionData(
                            value: count.toDouble(),
                            color: colors[idx % colors.length],
                            title: total > 0 ? '${(count / total * 100).toStringAsFixed(0)}%' : '0%',
                            titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            radius: sortedGenres.length > 8 ? 40 : 50,
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: sortedGenres.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final genre = entry.value.key;
                      final count = entry.value.value;
                      return _legendItem(colors[idx % colors.length], genre, count.toString());
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // EVENTS
  // ─────────────────────────────────────────────
  Widget _buildEventsContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
        }
        final events = snapshot.data?.docs ?? [];
        final approved = events.where((d) => (d.data() as Map)['status'] == 'approved').length;
        final pending = events.where((d) => (d.data() as Map)['status'] == 'pending').length;
        final rejected = events.where((d) => (d.data() as Map)['status'] == 'rejected').length;

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Todos los Eventos',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('${events.length} eventos', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (events.isEmpty)
                    const Center(child: Text('No hay eventos', style: TextStyle(color: AppColors.textSecondary)))
                  else
                    ...events.map((doc) {
                      final event = doc.data() as Map<String, dynamic>;
                      final status = event['status'] ?? 'pending';
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.surfaceLight)),
                        ),
                        child: ListTile(
                          onTap: () => _showEventDetail(event, doc.id),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              status == 'approved' ? Icons.check_circle : status == 'rejected' ? Icons.cancel : Icons.access_time,
                              color: status == 'approved' ? AppColors.success : status == 'rejected' ? AppColors.error : AppColors.warning,
                              size: 20,
                            ),
                          ),
                          title: Text(event['title'] ?? 'Evento', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          subtitle: Text('${event['artistName'] ?? '—'} • ${event['venue'] ?? '—'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Chart: event status distribution
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
                    'Estado de Eventos',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: approved.toDouble(),
                                  color: AppColors.success,
                                  title: pending + approved + rejected > 0
                                      ? '${(approved / (pending + approved + rejected) * 100).toStringAsFixed(0)}%'
                                      : '0%',
                                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  value: pending.toDouble(),
                                  color: AppColors.warning,
                                  title: pending + approved + rejected > 0
                                      ? '${(pending / (pending + approved + rejected) * 100).toStringAsFixed(0)}%'
                                      : '0%',
                                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  value: rejected.toDouble(),
                                  color: AppColors.error,
                                  title: pending + approved + rejected > 0
                                      ? '${(rejected / (pending + approved + rejected) * 100).toStringAsFixed(0)}%'
                                      : '0%',
                                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  radius: 50,
                                ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _legendItem(AppColors.success, 'Aprobados', approved.toString()),
                            const SizedBox(height: 8),
                            _legendItem(AppColors.warning, 'Pendientes', pending.toString()),
                            const SizedBox(height: 8),
                            _legendItem(AppColors.error, 'Rechazados', rejected.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserDetail(Map<String, dynamic> user, String userId, bool isArtist) {
    final photoUrl = user['photoUrl']?.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _getRoleColor(isArtist).withOpacity(0.2),
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? Text(
                      (user['name']?[0] ?? 'U').toString().toUpperCase(),
                      style: TextStyle(color: _getRoleColor(isArtist), fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user['name'] ?? 'Usuario',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('ID', userId),
              _detailRow('Nombre', user['name'] ?? '—'),
              _detailRow('Email', user['email'] ?? '—'),
              _detailRow('Rol', isArtist ? 'Artista' : 'Usuario'),
              if (user['musicalGenre'] != null)
                _detailRow('Género', user['musicalGenre']),
              if (user['instruments'] != null && (user['instruments'] as List).isNotEmpty)
                _detailRow('Instrumentos', (user['instruments'] as List).join(', ')),
              _detailRow('Registrado', _getFormattedDate(user['createdAt'])),
              if (user['bio'] != null && user['bio'].toString().isNotEmpty)
                _detailRow('Bio', user['bio']),
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

  void _showSongDetail(Map<String, dynamic> song, String songId) {
    final status = song['status'] ?? 'approved';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          song['title'] ?? 'Canción',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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

  void _showEventDetail(Map<String, dynamic> event, String eventId) {
    final status = event['status'] ?? 'pending';
    final dateStr = _getFormattedDate(event['eventDate']);
    final isExpired = event['eventDate'] != null
        ? (event['eventDate'] as Timestamp).toDate().isBefore(DateTime.now())
        : false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Expanded(
              child: Text(
                event['title'] ?? 'Evento',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            if (isExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Expirado',
                  style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Artista', event['artistName'] ?? '—'),
              _detailRow('Estado', status == 'approved' ? 'Aprobado' : status == 'rejected' ? 'Rechazado' : 'Pendiente'),
              _detailRow('Lugar', event['venue'] ?? '—'),
              _detailRow('Dirección', event['address'] ?? '—'),
              _detailRow('Fecha', dateStr),
              _detailRow('Precio', event['price'] ?? 'Gratis'),
              if (event['description'] != null && event['description'].toString().isNotEmpty)
                _detailRow('Descripción', event['description']),
              if (event['reviewMessage'] != null && event['reviewMessage'].toString().isNotEmpty)
                _detailRow('Motivo', event['reviewMessage']),
              _detailRow('ID', eventId),
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

  Widget _legendItem(Color color, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
