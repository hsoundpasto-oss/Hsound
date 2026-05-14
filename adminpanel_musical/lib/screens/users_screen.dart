import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
          ),
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
                  const SnackBar(
                    content: Text('Usuario eliminado correctamente'),
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

  Future<void> _syncEmails() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('syncUserEmails')
          .call();

      final data = result.data as Map<String, dynamic>;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sincronización completada: ${data['updated']} emails actualizados, ${data['skipped']} omitidos',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
                  backgroundImage: user['photoUrl'] != null
                      ? NetworkImage(user['photoUrl']!)
                      : null,
                  child: user['photoUrl'] == null
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
                const SizedBox(height: 16),
                const Text(
                  'Enlaces Sociales:',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user['youtubeUrl'] != null)
                  _buildSocialLink('YouTube', user['youtubeUrl']!),
                if (user['spotifyUrl'] != null)
                  _buildSocialLink('Spotify', user['spotifyUrl']!),
                if (user['instagramUrl'] != null)
                  _buildSocialLink('Instagram', user['instagramUrl']!),
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

  Widget _buildSocialLink(String platform, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        platform == 'YouTube'
            ? Icons.video_library
            : platform == 'Spotify'
                ? Icons.music_note
                : Icons.camera_alt,
        color: AppColors.primary,
        size: 20,
      ),
      title: Text(
        platform,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),
      subtitle: Text(
        url,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
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
                                backgroundImage: user['photoUrl'] != null
                                    ? NetworkImage(user['photoUrl']!)
                                    : null,
                                child: user['photoUrl'] == null
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
