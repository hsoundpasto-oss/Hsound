import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hsound/services/firestore_service.dart';
import '../../models/song_model.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String _selectedPlatform = 'youtube';
  bool _isLoading = false;
  String? _artistName;

  final List<Map<String, dynamic>> _platforms = [
    {
      'value': 'youtube',
      'label': 'YouTube',
      'icon': Icons.video_library,
      'color': Colors.red
    },
    {
      'value': 'spotify',
      'label': 'Spotify',
      'icon': Icons.music_note,
      'color': const Color(0xFF1DB954)
    },
    {
      'value': 'youtube_music',
      'label': 'YouTube Music',
      'icon': Icons.library_music,
      'color': Colors.red
    },
    {
      'value': 'soundcloud',
      'label': 'SoundCloud',
      'icon': Icons.cloud,
      'color': const Color(0xFFFF7700)
    },
    {
      'value': 'other',
      'label': 'Otra plataforma',
      'icon': Icons.link,
      'color': Colors.grey
    },
  ];

  // 🎯 MODIFICADO: Lista de géneros musicales (con Trap)
  final List<String> _genres = [
    'Rock',
    'Pop',
    'Hip Hop/Rap',
    'Trap',
    'Electrónica',
    'Reggaetón',
    'Salsa',
    'Merengue',
    'Vallenato',
    'Bachata',
    'Jazz',
    'Blues',
    'Clásica',
    'Reggae',
    'Metal',
    'Indie',
    'Folk',
    'R&B',
    'Country',
    'Alternativo',
    'Música Andina',
    'Bambuco',
    'Pasillo',
    'Dancehall',
    'Sanjuanero',
    'Carranga',
    'Música Popular',
    'Despecho',
    'Bolero',
    'Cumbia',
    'Champeta',
    'Fusión Andina',
    'Latin Trap',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _loadArtistName();
  }

  // Cargar nombre del artista desde el perfil
  Future<void> _loadArtistName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _artistName = data['name'] ?? 'Artista';
        });
      }
    }
  }

  // 🎯 MEJORADO: SnackBars con mejor contraste
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF15803D), // Verde más oscuro
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700], // Azul para información
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[700], // Naranja para advertencias
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Función para guardar la canción
  Future<void> _saveSong() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Crear objeto Song
          final song = Song(
            id: '',
            title: _titleController.text.trim(),
            artistId: user.uid,
            artistName: _artistName ?? 'Artista',
            platform: _selectedPlatform,
            url: _urlController.text.trim(),
            genre: _genreController.text,
            description: _descriptionController.text.trim(),
            duration: int.tryParse(_durationController.text) ?? 0,
            createdAt: DateTime.now(),
            searchKeywords: _firestoreService.createSearchKeywords(
              '${_titleController.text.trim()} ${_artistName ?? 'Artista'}',
            ),
          );

          // Guardar en Firestore
          await _firestoreService.saveSong(song);

          _showSuccessSnackBar(
              'Tu canción ha sido enviada para revisión. Los administradores la revisarán pronto.');

          Navigator.pop(context);
        }
      } catch (e) {
        _showErrorSnackBar('Error al guardar: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Validar URL según la plataforma seleccionada
  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la URL de la canción';
    }

    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'La URL debe comenzar con http:// o https://';
    }

    // Validaciones específicas por plataforma
    switch (_selectedPlatform) {
      case 'youtube':
        if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
          return 'URL de YouTube no válida. Debe ser de youtube.com o youtu.be';
        }

        // ✅ MEJORADO: Más formatos de YouTube soportados
        String? videoId;
        if (value.contains('youtu.be/')) {
          videoId = value.split('youtu.be/').last.split('?').first;
        } else if (value.contains('watch?v=')) {
          videoId = value.split('v=').last.split('&').first;
        } else if (value.contains('youtube.com/embed/')) {
          videoId = value.split('embed/').last.split('?').first;
        } else if (value.contains('youtube.com/v/')) {
          videoId = value.split('v/').last.split('?').first;
        }

        if (videoId != null && videoId.isNotEmpty) {
          _showInfoSnackBar('YouTube: Reproduccion embebida disponible');
        } else {
          return 'No se pudo detectar el ID del video de YouTube';
        }
        break;

      case 'spotify':
        if (!value.contains('spotify.com') &&
            !value.contains('open.spotify.com')) {
          return 'URL de Spotify no válida. Debe ser de open.spotify.com';
        }

        // Validar formato específico de Spotify
        if (!value.contains('/track/')) {
          return 'URL de Spotify debe ser de un track específico (contener /track/)';
        }

        // 🎯 MEJORADO: Mensaje informativo
        _showInfoSnackBar('Spotify: Widget oficial disponible');
        break;

      case 'soundcloud':
        if (!value.contains('soundcloud.com')) {
          return 'URL de SoundCloud no valida';
        }

        _showInfoSnackBar('SoundCloud: Se reproducira en la app');
        break;

      case 'youtube_music':
        if (!value.contains('music.youtube.com')) {
          return 'URL de YouTube Music no valida';
        }

        _showInfoSnackBar('YouTube Music: Reproduccion embebida disponible');
        break;

      default:
        _showWarningSnackBar(
            'Otra plataforma: Se intentara reproduccion embebida');
        break;
    }

    return null; // URL válida
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Color(0xFF4ADE80)),
        title: const Text(
          'Agregar Cancion',
          style: TextStyle(color: Color(0xFF4ADE80)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF4ADE80)),
            onPressed: _isLoading ? null : _saveSong,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4ADE80)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Información del artista
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF4ADE80).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Color(0xFF4ADE80)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Artista:',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _artistName ?? 'Cargando...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo: Título de la canción
                      _buildTextField(
                        controller: _titleController,
                        label: 'Título de la canción *',
                        hintText: 'Ej: Mi mejor canción',
                        icon: Icons.music_note,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el título';
                          }
                          if (value.length < 2) {
                            return 'El título debe tener al menos 2 caracteres';
                          }
                          return null;
                        },
                      ),

                      // Campo: Plataforma
                      _buildPlatformDropdown(),

                      // Campo: URL
                      _buildTextField(
                        controller: _urlController,
                        label: 'URL de la canción *',
                        hintText: _getUrlHintText(),
                        icon: Icons.link,
                        validator: _validateUrl,
                      ),

                      // Campo: Género
                      _buildGenreDropdown(),

                      // Campo: Duración
                      _buildTextField(
                        controller: _durationController,
                        label: 'Duración (segundos)',
                        hintText: 'Ej: 240 (4 minutos)',
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final duration = int.tryParse(value);
                            if (duration == null || duration <= 0) {
                              return 'Ingresa una duración válida en segundos';
                            }
                            if (duration > 3600) {
                              return 'La duración no puede ser mayor a 1 hora';
                            }
                          }
                          return null;
                        },
                      ),

                      // Campo: Descripción
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descripción (opcional)',
                        hintText: 'Describe tu canción, inspiración, letra...',
                        icon: Icons.description,
                        maxLines: 3,
                      ),

                      // Información de ayuda
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info,
                                color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getPlatformInfoText(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón de guardar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveSong,
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
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1E1E1E),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'GUARDAR CANCIÓN',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // 🎯 NUEVO: Texto de ayuda para URL según plataforma
  String _getUrlHintText() {
    switch (_selectedPlatform) {
      case 'youtube':
        return 'https://youtube.com/watch?v=... o https://youtu.be/...';
      case 'spotify':
        return 'https://open.spotify.com/track/...';
      case 'soundcloud':
        return 'https://soundcloud.com/usuario/cancion';
      case 'youtube_music':
        return 'https://music.youtube.com/watch?v=...';
      default:
        return 'https://...';
    }
  }

  // 🎯 NUEVO: Información específica por plataforma
  String _getPlatformInfoText() {
    switch (_selectedPlatform) {
      case 'youtube':
        return 'Tu cancion será revisada por los administradores antes de publicarse.';
      case 'spotify':
        return 'Solo tracks individuales (/track/). Widget oficial de Spotify.';
      case 'soundcloud':
        return 'Reproducción en la app. Asegúrate de que el enlace sea público.';
      case 'youtube_music':
        return 'Mismo sistema que YouTube. Reproducción embebida disponible.';
      default:
        return 'Se intentará reproducción embebida. Verifica que la URL sea accesible.';
    }
  }

  // Widget para campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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

  // Widget para seleccionar plataforma
  Widget _buildPlatformDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedPlatform,
        decoration: InputDecoration(
          labelText: 'Plataforma *',
          labelStyle: const TextStyle(color: Color(0xFF4ADE80)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4ADE80)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF86EFAC)),
          ),
          prefixIcon: const Icon(Icons.public, color: Color(0xFF4ADE80)),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
        ),
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white),
        items: _platforms.map((platform) {
          return DropdownMenuItem(
            value: platform['value'] as String,
            child: Row(
              children: [
                Icon(platform['icon'] as IconData,
                    color: platform['color'] as Color, size: 16),
                const SizedBox(width: 10),
                Text(platform['label'] as String),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedPlatform = value!;
            // Limpiar el campo de URL cuando cambia la plataforma
            _urlController.clear();
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor selecciona una plataforma';
          }
          return null;
        },
      ),
    );
  }

  // Widget para seleccionar género
  Widget _buildGenreDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _genreController.text.isEmpty ? null : _genreController.text,
        decoration: InputDecoration(
          labelText: 'Género musical *',
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
        items: _genres.map((genre) {
          return DropdownMenuItem(
            value: genre,
            child: Text(genre),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _genreController.text = value!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor selecciona un género';
          }
          return null;
        },
        hint: const Text(
          'Selecciona un género',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
