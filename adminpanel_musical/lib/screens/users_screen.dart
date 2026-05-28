import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  Color _getRoleColor(bool isArtist) {
    return isArtist ? AppColors.roleMusician : AppColors.roleUser;
  }

  String _getRoleLabel(bool isArtist) {
    return isArtist ? 'Artista' : 'Usuario';
  }

  void _showUserActions(String userId, Map<String, dynamic> user, BuildContext context) {
    final isArtist = user['isArtist'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isArtist ? Icons.person_off : Icons.person,
                color: AppColors.primary,
              ),
              title: Text(
                isArtist ? 'Quitar rol de artista' : 'Hacer artista',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleArtistRole(userId, !isArtist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                'Eliminar usuario',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteUser(userId, user['name'] ?? 'Usuario');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleArtistRole(String userId, bool makeArtist) async {
    try {
      if (makeArtist) {
        await _firestoreService.makeUserArtist(userId);
      } else {
        await _firestoreService.removeArtistRole(userId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            makeArtist
                ? 'Usuario convertido a artista exitosamente'
                : 'Rol de artista removido exitosamente',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _deleteUser(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '¿Eliminar usuario?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar a $userName? Esta acción no se puede deshacer.',
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
                await _firestoreService.deleteUser(userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Usuario eliminado correctamente', style: TextStyle(color: Colors.white)),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e', style: const TextStyle(color: Colors.white)),
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

  Future<void> _syncEmails() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Debes iniciar sesión para sincronizar', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Actualizar el email del admin actual en Firestore
      if (currentUser.email != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({'email': currentUser.email}, SetOptions(merge: true));
      }

      // Leer usuarios de Firestore y actualizar emails faltantes
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      int updated = 0;
      int skipped = 0;

      for (final userDoc in usersSnapshot.docs) {
        final data = userDoc.data();
        final email = data['email'] as String?;
        if (email == null || email.isEmpty) {
          // No podemos obtener el email de Auth desde el cliente
          // Marcar como pendiente
          await userDoc.reference.update({
            'emailSyncPending': true,
          });
          updated++;
        } else {
          skipped++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sincronización: $updated pendientes, $skipped actualizados'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isArtist = false;
    String selectedGenre = '';

    final List<String> genres = [
      'Rock', 'Pop', 'Hip Hop/Rap', 'Trap', 'Electrónica', 'Reggaetón',
      'Salsa', 'Merengue', 'Vallenato', 'Bachata', 'Jazz', 'Blues',
      'Clásica', 'Reggae', 'Metal', 'Indie', 'Folk', 'R&B', 'Country',
      'Alternativo', 'Música Andina', 'Bambuco', 'Pasillo', 'Dancehall',
      'Sanjuanero', 'Carranga', 'Música Popular', 'Despecho', 'Bolero',
      'Cumbia', 'Champeta', 'Fusión Andina', 'Latin Trap', 'Otro',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Crear Nuevo Usuario',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña (mín. 6 caracteres)',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text(
                        '¿Es artista?',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      value: isArtist,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setDialogState(() {
                          isArtist = value;
                          if (!value) selectedGenre = '';
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    if (isArtist) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedGenre.isEmpty ? null : selectedGenre,
                          underline: const SizedBox(),
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.textPrimary),
                          isExpanded: true,
                          hint: const Text('Seleccionar género', style: TextStyle(color: AppColors.textSecondary)),
                          items: genres.map((genre) => DropdownMenuItem(
                            value: genre,
                            child: Text(genre),
                          )).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedGenre = value ?? '';
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Todos los campos son obligatorios'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    if (password.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);
                    try {
                      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                        'name': name,
                        'email': email,
                        'isArtist': isArtist,
                        'musicalGenre': isArtist ? selectedGenre : '',
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Usuario "$name" creado exitosamente'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      String error = 'Error al crear usuario';
                      if (e.code == 'email-already-in-use') {
                        error = 'El correo ya está registrado';
                      } else if (e.code == 'invalid-email') {
                        error = 'Correo electrónico no válido';
                      } else if (e.code == 'weak-password') {
                        error = 'Contraseña muy débil';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error), backgroundColor: AppColors.error),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🔹 MÉTODO NUEVO: Mostrar detalles del usuario
  void _showUserDetails(String userId, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Detalles del Usuario',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _getRoleColor(user['isArtist'] == true).withOpacity(0.2),
                  backgroundImage: user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty
                      ? NetworkImage(user['photoUrl'])
                      : null,
                  child: user['photoUrl'] == null || user['photoUrl'].toString().isEmpty
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: _getRoleColor(user['isArtist'] == true),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailItem('Nombre', user['name'] ?? 'No disponible'),
              _buildDetailItem('Email', user['email'] ?? 'No disponible'),
              _buildDetailItem('Rol', _getRoleLabel(user['isArtist'] == true)),
              _buildDetailItem('Fecha de registro', _getFormattedDate(user['createdAt'])),

              if (user['bio'] != null && user['bio'].toString().isNotEmpty)
                _buildDetailItem('Biografía', user['bio']!),

              if (user['isArtist'] == true) ...[
                if (user['musicalGenre'] != null && user['musicalGenre'].toString().isNotEmpty)
                  _buildDetailItem('Género Musical', user['musicalGenre']!),

                if (user['instruments'] != null && (user['instruments'] as List).isNotEmpty)
                  _buildDetailItem('Instrumentos', (user['instruments'] as List).join(', ')),

                if (user['contactEmail'] != null && user['contactEmail'].toString().isNotEmpty)
                  _buildDetailItem('Email de contacto', user['contactEmail']!),

                const SizedBox(height: 16),
                const Text(
                  'Enlaces Sociales:',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user['youtubeUrl'] != null && user['youtubeUrl'].toString().isNotEmpty)
                  _buildSocialLink('youtube', 'YouTube', user['youtubeUrl']!),
                if (user['spotifyUrl'] != null && user['spotifyUrl'].toString().isNotEmpty)
                  _buildSocialLink('spotify', 'Spotify', user['spotifyUrl']!),
                if (user['instagramUrl'] != null && user['instagramUrl'].toString().isNotEmpty)
                  _buildSocialLink('instagram', 'Instagram', user['instagramUrl']!),
                if (user['facebookUrl'] != null && user['facebookUrl'].toString().isNotEmpty)
                  _buildSocialLink('facebook', 'Facebook', user['facebookUrl']!),
                if (user['tiktokUrl'] != null && user['tiktokUrl'].toString().isNotEmpty)
                  _buildSocialLink('tik-tok', 'TikTok', user['tiktokUrl']!),
                if (user['soundcloudUrl'] != null && user['soundcloudUrl'].toString().isNotEmpty)
                  _buildSocialLink('soundcloud', 'SoundCloud', user['soundcloudUrl']!),
                if (user['whatsappUrl'] != null && user['whatsappUrl'].toString().isNotEmpty)
                  _buildSocialLink('whatsapp', 'WhatsApp', user['whatsappUrl']!),

                const SizedBox(height: 16),
                const Text(
                  'Canciones:',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildUserSongsList(userId),

                const SizedBox(height: 16),
                const Text(
                  'Eventos:',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildUserEventsList(userId),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSocialLink(String platform, String label, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.asset('assets/images/$platform.png', width: 20, height: 20,
        errorBuilder: (c, e, s) => const Icon(Icons.link, color: AppColors.primary, size: 20)),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),
      subtitle: Text(
        url,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildUserSongsList(String userId) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestoreService.getSongsByArtist(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 24,
            child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        final songs = snapshot.data?.docs ?? [];
        if (songs.isEmpty) {
          return const Text('Sin canciones', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: songs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• ${data['title'] ?? 'Sin título'}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserEventsList(String userId) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestoreService.getEventsByArtist(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 24,
            child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        final events = snapshot.data?.docs ?? [];
        if (events.isEmpty) {
          return const Text('Sin eventos', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: events.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• ${data['title'] ?? 'Sin título'}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            );
          }).toList(),
        );
      },
    );
  }

  // 🔹 UI principal
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
                      'Gestión de Usuarios',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getAllUsers(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.docs.length ?? 0;
                        return Text(
                          '$count usuarios en total',
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
              ElevatedButton.icon(
                onPressed: _showCreateUserDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Crear Usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filtros
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o email...',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _selectedRoleFilter,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Todos los roles'),
                    ),
                    DropdownMenuItem(
                      value: 'artist',
                      child: Text('Artistas'),
                    ),
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('Usuarios'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sync, color: AppColors.primary),
                  tooltip: 'Sincronizar emails',
                  onPressed: _syncEmails,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Lista de usuarios
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final users = snapshot.data?.docs ?? [];

              final filteredUsers = users.where((userDoc) {
                final user = userDoc.data() as Map<String, dynamic>;
                final name = user['name']?.toString().toLowerCase() ?? '';
                final email = user['email']?.toString().toLowerCase() ?? '';
                final isArtist = user['isArtist'] == true;

                final matchesSearch = _searchQuery.isEmpty ||
                    name.contains(_searchQuery) ||
                    email.contains(_searchQuery);

                final matchesRole = _selectedRoleFilter == 'all' ||
                    (_selectedRoleFilter == 'artist' && isArtist) ||
                    (_selectedRoleFilter == 'user' && !isArtist);

                return matchesSearch && matchesRole;
              }).toList();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: filteredUsers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron usuarios',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final userDoc = filteredUsers[index];
                          final user = userDoc.data() as Map<String, dynamic>;
                          final isArtist = user['isArtist'] == true;

                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: index == filteredUsers.length - 1
                                      ? Colors.transparent
                                      : AppColors.surfaceLight,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getRoleColor(isArtist).withOpacity(0.2),
                                backgroundImage: user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty
                                    ? NetworkImage(user['photoUrl'])
                                    : null,
                                child: user['photoUrl'] == null || user['photoUrl'].toString().isEmpty
                                    ? Text(
                                        user['name']?[0].toUpperCase() ?? 'U',
                                        style: TextStyle(
                                          color: _getRoleColor(isArtist),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                user['name'] ?? 'Usuario',
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
                                    user['email'] ?? 'No email',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Registrado: ${_getFormattedDate(user['createdAt'])}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary
                                          .withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(isArtist)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getRoleLabel(isArtist),
                                      style: TextStyle(
                                        color: _getRoleColor(isArtist),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => _showUserActions(
                                      userDoc.id,
                                      user,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                              // 🔹 Agregamos la acción para mostrar los detalles
                              onTap: () => _showUserDetails(userDoc.id, user),
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
