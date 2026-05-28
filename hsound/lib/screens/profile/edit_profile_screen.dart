import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos editables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _spotifyController = TextEditingController();
  final TextEditingController _soundcloudController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isArtist = false;
  bool _isLoading = false;
  String _selectedGenre = '';
  Set<String> _selectedInstruments = {};

  final List<String> _genres = [
    'Rock', 'Pop', 'Hip Hop/Rap', 'Trap', 'Electrónica', 'Reggaetón',
    'Salsa', 'Merengue', 'Vallenato', 'Bachata', 'Jazz', 'Blues',
    'Clásica', 'Reggae', 'Metal', 'Indie', 'Folk', 'R&B', 'Country',
    'Alternativo', 'Música Andina', 'Bambuco', 'Pasillo', 'Dancehall',
    'Sanjuanero', 'Carranga', 'Música Popular', 'Despecho', 'Bolero',
    'Cumbia', 'Champeta', 'Fusión Andina', 'Latin Trap', 'Otro',
  ];

  final List<String> _instrumentOptions = [
    'Guitarra acústica', 'Guitarra eléctrica', 'Bajo eléctrico', 'Bajo acústico',
    'Charango', 'Tiple', 'Bandola', 'Cuatro', 'Arpa', 'Violín', 'Viola',
    'Violonchelo', 'Contrabajo', 'Mandolina', 'Ukelele',
    'Saxofón', 'Flauta traversa', 'Flauta dulce', 'Clarinete', 'Trompeta',
    'Trombón', 'Trompa', 'Tuba', 'Armónica', 'Acordeón', 'Ocarina',
    'Quena', 'Zampoña',
    'Batería', 'Percusión latina', 'Marimba', 'Xilófono', 'Tambores',
    'Djembé', 'Cajón peruano', 'Pandereta',
    'Piano', 'Teclado', 'Órgano', 'Sintetizador', 'Acordeón a piano',
    'Voz soprano', 'Voz mezzosoprano', 'Voz contralto', 'Voz tenor',
    'Voz barítono', 'Voz bajo', 'Voz lírica', 'Voz popular',
    'Controlador MIDI', 'Sampler', 'Drum machine', 'Toca discos (DJ)',
    'Mesa de mezclas', 'Producción musical',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Cargar datos existentes del usuario
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userProfile = await _firestoreService.getUserProfile();
      if (userProfile.exists) {
        final data = userProfile.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _youtubeController.text = data['youtubeUrl'] ?? '';
          _spotifyController.text = data['spotifyUrl'] ?? '';
          _soundcloudController.text = data['soundcloudUrl'] ?? ''; // 🎵 NUEVO
          _instagramController.text = data['instagramUrl'] ?? '';
          _tiktokController.text = data['tiktokUrl'] ?? '';
          _whatsappController.text = data['whatsappUrl'] ?? '';
          _facebookController.text = data['facebookUrl'] ?? '';
          _emailController.text = data['contactEmail'] ?? '';
          _isArtist = data['isArtist'] ?? false;
          _selectedGenre = data['musicalGenre'] ?? '';
          if (data['instruments'] != null) {
            _selectedInstruments = Set<String>.from(data['instruments'] as List);
          }
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      _showErrorSnackBar('Error al cargar perfil: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🎯 MEJORADO: SnackBar con mejor contraste
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF15803D), // Verde más oscuro
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

  // Guardar perfil - CORREGIDO
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updateData = <String, dynamic>{
          'name': _nameController.text,
          'bio': _bioController.text,
          'youtubeUrl': _normalizeUrl(_youtubeController.text),
          'spotifyUrl': _normalizeUrl(_spotifyController.text),
          'soundcloudUrl': _normalizeUrl(_soundcloudController.text),
          'instagramUrl': _normalizeUrl(_instagramController.text),
          'tiktokUrl': _normalizeUrl(_tiktokController.text),
          'whatsappUrl': _normalizeUrl(_whatsappController.text),
          'facebookUrl': _normalizeUrl(_facebookController.text),
          'contactEmail': _emailController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (_isArtist) {
          updateData['musicalGenre'] = _selectedGenre;
          updateData['instruments'] = _selectedInstruments.toList();
        }
        await _firestoreService.updateUserProfile(updateData);

        _showSuccessSnackBar('Perfil actualizado correctamente');
        
        Navigator.pop(context);
      } catch (e) {
        print('Error saving profile: $e');
        _showErrorSnackBar('Error al guardar: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  String? _urlValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final trimmed = value.trim();
    final normalized = trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.isAbsolute || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Ingresa una URL válida (ej. https://...)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Color(0xFF4ADE80)),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Color(0xFF4ADE80)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF4ADE80)),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Información del estado de artista
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isArtist 
                              ? const Color(0xFF15803D).withOpacity(0.2) 
                              : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isArtist 
                                ? const Color(0xFF4ADE80) 
                                : const Color(0xFF2D2D2D),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isArtist ? Icons.verified : Icons.person,
                              color: _isArtist ? const Color(0xFF4ADE80) : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isArtist ? 'Cuenta de Artista' : 'Cuenta de Usuario',
                                    style: TextStyle(
                                      color: _isArtist ? const Color(0xFF4ADE80) : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _isArtist 
                                        ? 'Puedes agregar canciones y mostrar tus redes' 
                                        : 'Para convertirte en artista ve a tu perfil',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Campo nombre
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre',
                        hintText: 'Tu nombre o nombre artístico',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          if (value.length < 2) {
                            return 'El nombre debe tener al menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      
                      _buildTextField(
                        controller: _bioController,
                        label: 'Biografía',
                        hintText: 'Cuéntanos sobre ti, tu música, inspiración...',
                        icon: Icons.description,
                        maxLines: null,
                      ),
                      
                      // Solo para artistas: enlaces de música y redes
                      if (_isArtist) ...[
                        const SizedBox(height: 20),
                        _buildSectionHeader('Género Musical'),
                        _buildGenreDropdown(),
                        const SizedBox(height: 20),
                        _buildSectionHeader('Instrumentos que tocas'),
                        _buildInstrumentsSelector(),
                        const SizedBox(height: 20),
                        _buildSectionHeader('Enlaces de Musica'),
                        
                        _buildSocialTextField(
                          controller: _youtubeController,
                          label: 'YouTube',
                          hintText: 'https://youtube.com/@tucanal',
                          platform: 'youtube',
                          validator: _urlValidator,
                        ),
                        
                        _buildSocialTextField(
                          controller: _spotifyController,
                          label: 'Spotify',
                          hintText: 'https://open.spotify.com/artist/tu-id',
                          platform: 'spotify',
                          validator: _urlValidator,
                        ),

                        _buildSocialTextField(
                          controller: _soundcloudController,
                          label: 'SoundCloud',
                          hintText: 'https://soundcloud.com/tu-usuario',
                          platform: 'soundcloud',
                          validator: _urlValidator,
                        ),

                        _buildSocialTextField(
                          controller: _tiktokController,
                          label: 'TikTok',
                          hintText: 'https://tiktok.com/@tu-usuario',
                          platform: 'tik-tok',
                          validator: _urlValidator,
                        ),
                        
                        const SizedBox(height: 20),
                        _buildSectionHeader('Redes Sociales'),
                        
                        _buildSocialTextField(
                          controller: _instagramController,
                          label: 'Instagram',
                          hintText: 'https://instagram.com/tu-usuario',
                          platform: 'instagram',
                          validator: _urlValidator,
                        ),

                        _buildSocialTextField(
                          controller: _facebookController,
                          label: 'Facebook',
                          hintText: 'https://facebook.com/tu-pagina',
                          platform: 'facebook',
                          validator: _urlValidator,
                        ),

                        const SizedBox(height: 20),
                        _buildSectionHeader('Contacto/Booking'),
                        
                        _buildSocialTextField(
                          controller: _whatsappController,
                          label: 'WhatsApp',
                          hintText: 'https://wa.me/573001234567',
                          platform: 'whatsapp',
                          validator: _urlValidator,
                        ),

                        _buildSocialTextField(
                          controller: _emailController,
                          label: 'Email de Contacto',
                          hintText: 'artista@email.com',
                          platform: 'gmail',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Ingresa un email válido';
                              }
                            }
                            return null;
                          },
                        ),
                      ],

                      // Botón de guardar
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ADE80),
                            foregroundColor: const Color(0xFF1E1E1E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1E1E1E),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'GUARDAR CAMBIOS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildGenreDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedGenre.isEmpty ? null : _selectedGenre,
        decoration: InputDecoration(
          labelText: 'Género musical',
          labelStyle: const TextStyle(color: Color(0xFF4ADE80)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4ADE80)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF86EFAC)),
          ),
          prefixIcon: const Icon(Icons.category, color: Color(0xFF4ADE80)),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
        ),
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white),
        items: _genres.map((genre) => DropdownMenuItem(
          value: genre,
          child: Text(genre),
        )).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGenre = value ?? '';
          });
        },
        hint: const Text('Selecciona tu género', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildInstrumentsSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2D2D2D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedInstruments.isEmpty
                ? 'Selecciona los instrumentos que tocas'
                : '${_selectedInstruments.length} instrumento(s) seleccionado(s)',
            style: TextStyle(
              color: _selectedInstruments.isEmpty ? Colors.grey : const Color(0xFF4ADE80),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _instrumentOptions.map((instrument) {
              final selected = _selectedInstruments.contains(instrument);
              return FilterChip(
                label: Text(
                  instrument,
                  style: TextStyle(
                    color: selected ? const Color(0xFF1E1E1E) : Colors.white,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: selected,
                selectedColor: const Color(0xFF4ADE80),
                checkmarkColor: const Color(0xFF1E1E1E),
                backgroundColor: const Color(0xFF2D2D2D),
                onSelected: (isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedInstruments.add(instrument);
                    } else {
                      _selectedInstruments.remove(instrument);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4ADE80)),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4ADE80)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF86EFAC)),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF4ADE80)),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
        ),
        validator: validator,
      ),
    );
  }

  // 🎯 NUEVO: Campo para redes sociales con validación opcional
  Widget _buildSocialTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String platform,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4ADE80)),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2D2D2D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4ADE80)),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset('assets/images/$platform.png', width: 20, height: 20,
              errorBuilder: (c, e, s) => const Icon(Icons.link, color: Color(0xFF4ADE80), size: 20)),
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _youtubeController.dispose();
    _spotifyController.dispose();
    _soundcloudController.dispose(); // 🎵 NUEVO
    _instagramController.dispose();
    _tiktokController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}