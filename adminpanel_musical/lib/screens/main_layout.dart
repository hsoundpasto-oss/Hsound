import 'package:adminpanel_musical/screens/songs_screen.dart';
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

  // Solo las pantallas que realmente usamos
  Widget _getCurrentScreen() {
    switch (_currentRoute) {
      case '/dashboard':
        return const DashboardScreen();
      case '/users':
        return const UsersScreen();
      case '/songs':
        return const SongsScreen(); // ← AGREGAR ESTA LÍNEA
      default:
        return const DashboardScreen();
    }
  }

  String _getCurrentTitle() {
    switch (_currentRoute) {
      case '/dashboard':
        return 'Dashboard';
      case '/users':
        return 'Gestión de Usuarios';
      case '/songs':
        return 'Todas las Canciones'; // ← AGREGAR ESTA LÍNEA
      default:
        return 'Panel Admin HSound';
    }
  }

  void _handleNavigation(String route) {
    setState(() {
      _currentRoute = route;
    });
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
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
                              // Forzar recarga de datos
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Datos actualizados'),
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
