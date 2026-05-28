import 'package:adminpanel_musical/screens/reviews_screen.dart';
import 'package:adminpanel_musical/screens/songs_screen.dart';
import 'package:adminpanel_musical/screens/events_screen.dart';
import 'package:adminpanel_musical/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/sidebar.dart';
import 'dashboard_screen.dart';
import 'users_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _currentRoute = '/dashboard';
  int _refreshCounter = 0;

  // Solo las pantallas que realmente usamos
  Widget _getCurrentScreen() {
    switch (_currentRoute) {
      case '/dashboard':
        return DashboardScreen(
          key: ValueKey('dash_$_refreshCounter'),
          onNavigate: _handleNavigation,
        );
      case '/users':
        return UsersScreen(key: ValueKey('users_$_refreshCounter'));
      case '/songs':
        return SongsScreen(key: ValueKey('songs_$_refreshCounter'));
      case '/reviews':
        return ReviewsScreen(key: ValueKey('reviews_$_refreshCounter'));
      case '/events':
        return EventsScreen(key: ValueKey('events_$_refreshCounter'));
      default:
        return DashboardScreen(
          key: ValueKey('dash_$_refreshCounter'),
          onNavigate: _handleNavigation,
        );
    }
  }

  String _getCurrentTitle() {
    switch (_currentRoute) {
      case '/dashboard':
        return 'Dashboard';
      case '/users':
        return 'Gestión de Usuarios';
      case '/songs':
        return 'Todas las Canciones';
      case '/reviews':
        return 'Revisiones';
      case '/events':
        return 'Gestión de Eventos';
      default:
        return 'Panel Admin HSound';
    }
  }

  void _handleNavigation(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  void _showCreateAdminDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Crear Nuevo Administrador',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'El nuevo administrador podrá iniciar sesión en el panel con su email y contraseña.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
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
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
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
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (name.isEmpty ||
                          email.isEmpty ||
                          password.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Completa todos los campos (contraseña mín. 6 caracteres)',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      final authService = AuthService();
                      final result = await authService.createAdmin(
                        email,
                        password,
                        name,
                      );

                      setDialogState(() => isLoading = false);

                      if (result['success'] == true) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Administrador "$name" creado exitosamente',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${result['message']}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear Admin'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminProfile(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Información del admin
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text(
                'Nombre',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                auth.currentUser?.name ?? 'Administrador',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text(
                'Email',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                auth.currentUser?.email ?? 'admin@musical.com',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.admin_panel_settings,
                color: AppColors.primary,
              ),
              title: const Text(
                'Rol',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Administrador',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAdminPassword(context, auth.currentUser?.email ?? '');
            },
            child: const Text(
              'Restablecer mi contraseña',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _resetAdminPassword(BuildContext context, String email) {
    if (email.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Restablecer contraseña',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Se enviará un correo de restablecimiento a $email. ¿Deseas continuar?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Correo enviado a $email'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión del panel administrativo?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar simplificado
          Sidebar(
            currentRoute: _currentRoute,
            onNavigate: _handleNavigation,
            showApprovals: false, // ← Oculta aprobaciones
            showSettings: false, // ← Oculta configuración
          ),

          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Header superior MEJORADO
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.surfaceLight),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Título de la sección actual
                      Text(
                        _getCurrentTitle(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Iconos de la derecha MEJORADOS
                      Row(
                        children: [
                          // Botón de actualizar datos
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              setState(() {
                                _refreshCounter++;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Datos recargados'),
                                  backgroundColor: AppColors.success,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            tooltip: 'Actualizar datos',
                          ),

                          const SizedBox(width: 8),

                          // Perfil del admin con menú desplegable
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.account_circle,
                              size: 32,
                              color: AppColors.textSecondary,
                            ),
                            color: AppColors.surface,
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.person,
                                    color: AppColors.textPrimary,
                                    size: 20,
                                  ),
                                  title: const Text(
                                    'Mi perfil',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showAdminProfile(context);
                                  },
                                ),
                              ),
                              PopupMenuItem<String>(
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.admin_panel_settings,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  title: const Text(
                                    'Crear Administrador',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showCreateAdminDialog(context);
                                  },
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.logout,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  title: const Text(
                                    'Cerrar sesión',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showLogoutConfirmation(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contenido de la pantalla actual
                Expanded(child: _getCurrentScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
