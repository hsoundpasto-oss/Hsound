import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchControllerSongs = TextEditingController();
  final TextEditingController _searchControllerEvents = TextEditingController();
  late TabController _tabController;
  String _songFilter = 'pending';
  String _eventFilter = 'pending';
  String _songSearch = '';
  String _eventSearch = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchControllerSongs.dispose();
    _searchControllerEvents.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } catch (_) {
      try {
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('URL copiada al portapapeles'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('URL: $url', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _approveSong(String songId, String title) async {
    try {
      final admin = FirebaseAuth.instance.currentUser;
      await _firestoreService.approveSong(songId, admin?.uid ?? '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$title" aprobada', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectSong(String songId, String title) async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rechazar Canción', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Motivo para rechazar "$title":', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe el motivo del rechazo...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        final admin = FirebaseAuth.instance.currentUser;
        await _firestoreService.rejectSong(songId, result, admin?.uid ?? '');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$title" rechazada', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _approveEvent(String eventId, String title) async {
    try {
      final admin = FirebaseAuth.instance.currentUser;
      await _firestoreService.approveEvent(eventId, admin?.uid ?? '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$title" aprobado', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectEvent(String eventId, String title) async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rechazar Evento', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Motivo para rechazar "$title":', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe el motivo del rechazo...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        final admin = FirebaseAuth.instance.currentUser;
        await _firestoreService.rejectEvent(eventId, result, admin?.uid ?? '');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$title" rechazado', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Revisiones',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Canciones y eventos pendientes de revisión',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(icon: Icon(Icons.music_note), text: 'Canciones'),
                    Tab(icon: Icon(Icons.event), text: 'Eventos'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSongsTab(),
              _buildEventsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSongsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchControllerSongs,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o artista...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _songSearch.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchControllerSongs.clear();
                              setState(() => _songSearch = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => _songSearch = value.toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _songFilter,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                    DropdownMenuItem(value: 'approved', child: Text('Aprobadas')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rechazadas')),
                  ],
                  onChanged: (value) => setState(() => _songFilter = value!),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getSongsByStatus(_songFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              var songs = snapshot.data?.docs ?? [];
              if (_songSearch.isNotEmpty) {
                songs = songs.where((doc) {
                  final s = doc.data() as Map<String, dynamic>;
                  final title = (s['title'] ?? '').toString().toLowerCase();
                  final artist = (s['artistName'] ?? '').toString().toLowerCase();
                  return title.contains(_songSearch) || artist.contains(_songSearch);
                }).toList();
              }
              if (songs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_off, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text('No hay canciones ${_getFilterLabel(_songFilter)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                );
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final songDoc = songs[index];
                    final song = songDoc.data() as Map<String, dynamic>;
                    final status = song['status'] ?? 'pending';
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: index == songs.length - 1 ? Colors.transparent : AppColors.surfaceLight)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            status == 'pending' ? Icons.access_time : status == 'rejected' ? Icons.cancel : Icons.check_circle,
                            color: status == 'pending' ? AppColors.warning : status == 'rejected' ? AppColors.error : AppColors.success,
                          ),
                        ),
                        title: Text(song['title'] ?? 'Sin título',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${song['artistName'] ?? 'Artista'} • ${song['genre'] ?? 'Género'}',
                              style: const TextStyle(color: AppColors.textSecondary)),
                            if (song['reviewMessage'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('Motivo: ${song['reviewMessage']}',
                                  style: const TextStyle(color: AppColors.error, fontSize: 12, fontStyle: FontStyle.italic)),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status == 'pending') ...[
                              IconButton(
                                icon: const Icon(Icons.open_in_new, color: AppColors.info),
                                tooltip: 'Abrir enlace',
                                onPressed: () => _launchUrl(song['url'] ?? ''),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check, color: AppColors.success),
                                tooltip: 'Aprobar',
                                onPressed: () => _approveSong(songDoc.id, song['title'] ?? 'Canción'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: AppColors.error),
                                tooltip: 'Rechazar',
                                onPressed: () => _rejectSong(songDoc.id, song['title'] ?? 'Canción'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchControllerEvents,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o artista...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _eventSearch.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchControllerEvents.clear();
                              setState(() => _eventSearch = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => _eventSearch = value.toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _eventFilter,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                    DropdownMenuItem(value: 'approved', child: Text('Aprobados')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rechazados')),
                  ],
                  onChanged: (value) => setState(() => _eventFilter = value!),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getEventsByStatus(_eventFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              var events = snapshot.data?.docs ?? [];
              if (_eventSearch.isNotEmpty) {
                events = events.where((doc) {
                  final e = doc.data() as Map<String, dynamic>;
                  final title = (e['title'] ?? '').toString().toLowerCase();
                  final artist = (e['artistName'] ?? '').toString().toLowerCase();
                  return title.contains(_eventSearch) || artist.contains(_eventSearch);
                }).toList();
              }
              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text('No hay eventos ${_getFilterLabel(_eventFilter)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                );
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final eventDoc = events[index];
                    final event = eventDoc.data() as Map<String, dynamic>;
                    final status = event['status'] ?? 'pending';
                    final isExpired = _isExpired(event['eventDate']);
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: index == events.length - 1 ? Colors.transparent : AppColors.surfaceLight)),
                      ),
                      child: ListTile(
                        onTap: () => _showEventDetail(event, eventDoc.id),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            status == 'pending' ? Icons.access_time : status == 'rejected' ? Icons.cancel : Icons.check_circle,
                            color: status == 'pending' ? AppColors.warning : status == 'rejected' ? AppColors.error : AppColors.success,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(event['title'] ?? 'Evento',
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${event['artistName'] ?? 'Artista'} • ${event['venue'] ?? ''}',
                              style: const TextStyle(color: AppColors.textSecondary)),
                            Text('Fecha: ${_getFormattedDate(event['eventDate'])}',
                              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12)),
                            if (event['reviewMessage'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('Motivo: ${event['reviewMessage']}',
                                  style: const TextStyle(color: AppColors.error, fontSize: 12, fontStyle: FontStyle.italic)),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (event['googleMapsUrl'] != null &&
                                event['googleMapsUrl'].toString().isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.map, color: AppColors.info),
                                tooltip: 'Abrir mapa',
                                onPressed: () => _launchMapsUrl(event['googleMapsUrl']),
                              ),
                            if (status == 'pending') ...[
                              IconButton(
                                icon: const Icon(Icons.check, color: AppColors.success),
                                tooltip: 'Aprobar',
                                onPressed: () => _approveEvent(eventDoc.id, event['title'] ?? 'Evento'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: AppColors.error),
                                tooltip: 'Rechazar',
                                onPressed: () => _rejectEvent(eventDoc.id, event['title'] ?? 'Evento'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEventDetail(Map<String, dynamic> event, String eventId) {
    final status = event['status'] ?? 'pending';
    final isExpired = _isExpired(event['eventDate']);
    final dateStr = _getFormattedDate(event['eventDate']);

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
              if (event['reviewedAt'] != null)
                _detailRow('Revisado', _getFormattedDate(event['reviewedAt'])),
              _detailRow('ID', eventId),
            ],
          ),
        ),
        actions: [
          if (event['googleMapsUrl'] != null && event['googleMapsUrl'].toString().isNotEmpty)
            TextButton.icon(
              onPressed: () => _launchMapsUrl(event['googleMapsUrl']),
              icon: const Icon(Icons.map, color: AppColors.info, size: 18),
              label: const Text('Ver mapa', style: TextStyle(color: AppColors.info)),
            ),
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

  Future<void> _launchMapsUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!uri.isAbsolute || (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw Exception('URL inválida');
      }
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No es posible abrir esta ubicación. Verifica que el enlace sea válido.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'pending': return 'pendientes';
      case 'approved': return 'aprobadas';
      case 'rejected': return 'rechazadas';
      default: return '';
    }
  }

  bool _isExpired(dynamic eventDate) {
    if (eventDate == null) return false;
    try {
      if (eventDate is Timestamp) {
        return eventDate.toDate().isBefore(DateTime.now());
      }
      return false;
    } catch (e) {
      return false;
    }
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
