import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event_model.dart';
import '../../services/firestore_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _addressController = TextEditingController();
  final _mapsUrlController = TextEditingController();
  final _priceAmountController = TextEditingController();
  final _priceCustomController = TextEditingController();
  bool _isLoading = false;
  late DateTime _eventDate;
  String _priceType = 'free';

  @override
  void initState() {
    super.initState();
    _eventDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _mapsUrlController.dispose();
    _priceAmountController.dispose();
    _priceCustomController.dispose();
    super.dispose();
  }

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4ADE80),
              onPrimary: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_eventDate),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4ADE80),
                onPrimary: Color(0xFF1E1E1E),
              ),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          _eventDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = (userDoc.data()?['name'] ?? 'Artista').toString();

      final event = Event(
        id: '',
        artistId: user.uid,
        artistName: userName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        venue: _venueController.text.trim(),
        address: _addressController.text.trim(),
        googleMapsUrl: _mapsUrlController.text.trim().isEmpty
            ? null
            : _mapsUrlController.text.trim(),
        eventDate: _eventDate,
        price: _getPriceValue(),
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _firestoreService.saveEvent(event);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Evento creado. Los administradores lo revisarán pronto.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Agregar Evento',
          style: TextStyle(color: Color(0xFF4ADE80)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF4ADE80)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información del Evento'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _titleController,
                label: 'Título del evento *',
                hint: 'Ej: Concierto de Rock en Pasto',
                validator: (v) => v!.isEmpty ? 'Ingresa el título' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descriptionController,
                label: 'Descripción (opcional)',
                hint: 'Describe los detalles del evento...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Lugar'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _venueController,
                label: 'Nombre del lugar *',
                hint: 'Ej: Teatro Imperial',
                validator: (v) => v!.isEmpty ? 'Ingresa el lugar' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                label: 'Dirección *',
                hint: 'Ej: Calle 18 # 7-32, Pasto',
                validator: (v) => v!.isEmpty ? 'Ingresa la dirección' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _mapsUrlController,
                label: 'Google Maps URL (opcional)',
                hint: 'https://maps.google.com/?q=...',
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final uri = Uri.tryParse(v.trim());
                    if (uri == null || !uri.isAbsolute) {
                      return 'Ingresa una URL válida';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Fecha y Precio'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D2D2D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF4ADE80)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fecha: ${_eventDate.day}/${_eventDate.month}/${_eventDate.year} ${_eventDate.hour.toString().padLeft(2, '0')}:${_eventDate.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                      const Icon(Icons.edit, color: Colors.grey, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildPriceSelector(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF4ADE80),
                    foregroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1E1E1E),
                          ),
                        )
                      : const Text(
                          'Publicar Evento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu evento será revisado por los administradores antes de publicarse.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D2D2D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Precio', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPriceOption('Gratis', 'free'),
              const SizedBox(width: 8),
              _buildPriceOption('Pago', 'paid'),
              const SizedBox(width: 8),
              _buildPriceOption('Otro', 'custom'),
            ],
          ),
          if (_priceType == 'paid') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _priceAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: const TextStyle(color: Color(0xFF4ADE80), fontSize: 16, fontWeight: FontWeight.bold),
                hintText: 'Ej: 10000',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2D2D2D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          if (_priceType == 'custom') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _priceCustomController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej: Entrada libre, Donación voluntaria...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2D2D2D),
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

  Widget _buildPriceOption(String label, String value) {
    final isSelected = _priceType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priceType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4ADE80).withOpacity(0.2) : const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF4ADE80) : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4ADE80) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF4ADE80),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D2D2D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D2D2D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4ADE80)),
        ),
      ),
    );
  }
}
