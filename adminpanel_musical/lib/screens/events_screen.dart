import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mapsUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _artistIdController = TextEditingController();
  final TextEditingController _artistNameController = TextEditingController();
  final TextEditingController _priceAmountController = TextEditingController();
  final TextEditingController _priceCustomController = TextEditingController();

  String _searchQuery = '';
  String _priceType = 'free';

  String _getPriceValue() {
    switch (_priceType) {
      case 'free':
        return 'Gratis';
      case 'paid':
        final amount = _priceAmountController.text.trim();
        if (amount.isEmpty) return 'Gratis';
        final numeric = amount.replaceAll(RegExp(r'[^0-9]'), '');
        if (numeric.isEmpty) return 'Gratis';
        return '\$$numeric';
      case 'custom':
        final text = _priceCustomController.text.trim();
        return text.isEmpty ? 'Entrada libre' : text;
      default:
        return 'Gratis';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _mapsUrlController.dispose();
    _priceController.dispose();
    _artistIdController.dispose();
    _artistNameController.dispose();
    _priceAmountController.dispose();
    _priceCustomController.dispose();
    super.dispose();
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
          content: const Text('No es posible abrir esta ubicación. Verifica que el enlace de Google Maps sea válido.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }


  Future<void> _showAddEventDialog() async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    Map<String, String> errors = {};
    void validateAndSetErrors() {
      final e = <String, String>{};
      if (_artistIdController.text.trim().isEmpty) e['artistId'] = 'Campo requerido';
      if (_artistNameController.text.trim().isEmpty) e['artistName'] = 'Campo requerido';
      if (_titleController.text.trim().isEmpty) e['title'] = 'Campo requerido';
      if (_venueController.text.trim().isEmpty) e['venue'] = 'Campo requerido';
      if (_addressController.text.trim().isEmpty) e['address'] = 'Campo requerido';
      errors = e;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Agregar Evento Manual',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _artistIdController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('ID del Artista (UID)',
                      error: errors['artistId']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _artistNameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Nombre del Artista',
                      error: errors['artistName']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Título del Evento',
                      error: errors['title']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Descripción (opcional)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _venueController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Lugar (ej: Teatro Imperial)',
                      error: errors['venue']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Dirección completa',
                      error: errors['address']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _mapsUrlController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Google Maps URL (opcional)'),
                ),
                const SizedBox(height: 12),
                _buildPriceSelectorTheme(context, setDialogState),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedDate)}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (picked != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: const Text('Seleccionar Fecha'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                setDialogState(() {
                  validateAndSetErrors();
                });
                if (errors.isNotEmpty) return;

                try {
                  await _firestoreService.createEvent(
                    artistId: _artistIdController.text.trim(),
                    artistName: _artistNameController.text.trim(),
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim().isEmpty
                        ? null
                        : _descriptionController.text.trim(),
                    venue: _venueController.text.trim(),
                    address: _addressController.text.trim(),
                    googleMapsUrl: _mapsUrlController.text.trim().isEmpty
                        ? null
                        : _mapsUrlController.text.trim(),
                    eventDate: selectedDate,
                    price: _getPriceValue(),
                  );
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Evento creado exitosamente',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear Evento'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _titleController.clear();
      _descriptionController.clear();
      _venueController.clear();
      _addressController.clear();
      _mapsUrlController.clear();
      _priceController.clear();
      _artistIdController.clear();
      _artistNameController.clear();
    }
  }

  InputDecoration _inputDecoration(String label, {String? error}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      errorText: error,
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: error != null ? const BorderSide(color: AppColors.error) : BorderSide.none,
      ),
    );
  }

  Widget _buildPriceSelectorTheme(BuildContext context, StateSetter dialogSetState) {
    final Color accent = const Color(0xFF4ADE80);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Precio', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _priceOption('Gratis', 'free', dialogSetState),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _priceOption('Pago', 'paid', dialogSetState),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _priceOption('Otro', 'custom', dialogSetState),
              ),
            ],
          ),
          if (_priceType == 'paid') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _priceAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.bold),
                hintText: 'Ej: 10000',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          if (_priceType == 'custom') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _priceCustomController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ej: Entrada libre, Donación voluntaria...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceOption(String label, String value, StateSetter dialogSetState) {
    final isSelected = _priceType == value;
    final Color accent = const Color(0xFF4ADE80);
    return GestureDetector(
      onTap: () {
        dialogSetState(() => _priceType = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accent : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? accent : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Todos los Eventos',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getAllEvents(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.docs.length ?? 0;
                        return Text(
                          '$count eventos en total',
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
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAddEventDialog,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Buscar por título o artista...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
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
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getAllEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              var events = snapshot.data?.docs ?? [];

              if (_searchQuery.isNotEmpty) {
                events = events.where((doc) {
                  final e = doc.data() as Map<String, dynamic>;
                  final title = (e['title'] ?? '').toString().toLowerCase();
                  final artist = (e['artistName'] ?? '').toString().toLowerCase();
                  return title.contains(_searchQuery) || artist.contains(_searchQuery);
                }).toList();
              }

              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay eventos',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
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
                        border: Border(
                          bottom: BorderSide(
                            color: index == events.length - 1
                                ? Colors.transparent
                                : AppColors.surfaceLight,
                          ),
                        ),
                      ),
                      child: ListTile(
                        onTap: () => _showEventDetail(eventDoc.id, event),
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
                          child: Icon(
                            status == 'pending'
                                ? Icons.access_time
                                : status == 'rejected'
                                ? Icons.cancel
                                : Icons.check_circle,
                            color: status == 'pending'
                                ? AppColors.warning
                                : status == 'rejected'
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                event['title'] ?? 'Sin título',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isExpired)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Expirado',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${event['artistName'] ?? 'Artista'} • ${event['venue'] ?? ''}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            Text(
                              'Fecha: ${_getFormattedDate(event['eventDate'])}',
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            if (event['reviewMessage'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Motivo: ${event['reviewMessage']}',
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
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
        const SizedBox(height: 24),
      ],
    );
  }

  bool _isExpired(dynamic eventDate) {
    if (eventDate == null) return false;
    try {
      DateTime date;
      if (eventDate is Timestamp) {
        date = eventDate.toDate();
      } else {
        return false;
      }
      return date.isBefore(DateTime.now());
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
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Fecha desconocida';
    }
  }

  void _showEventDetail(String eventId, Map<String, dynamic> event) {
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
}
