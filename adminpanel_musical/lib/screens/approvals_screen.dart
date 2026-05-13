import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/approval_model.dart';
import 'package:intl/intl.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  String _selectedTypeFilter = 'all';

  // Datos de ejemplo
  List<ApprovalModel> _approvals = [
    ApprovalModel(
      id: '1',
      type: 'cover',
      title: 'Carátula de álbum "Ritmos del Sur"',
      description: 'Nueva carátula para mi próximo álbum',
      submittedBy: '2',
      submittedByName: 'Juan Pérez',
      imageUrl: 'https://via.placeholder.com/300x300',
      submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ApprovalModel(
      id: '2',
      type: 'link',
      title: 'Link de Spotify',
      description: 'Mi perfil de artista en Spotify',
      submittedBy: '3',
      submittedByName: 'María García',
      contentUrl: 'https://open.spotify.com/artist/ejemplo',
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ApprovalModel(
      id: '3',
      type: 'cover',
      title: 'Banner de evento',
      description: 'Banner promocional para concierto',
      submittedBy: '2',
      submittedByName: 'Juan Pérez',
      imageUrl: 'https://via.placeholder.com/600x200',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ApprovalModel(
      id: '4',
      type: 'link',
      title: 'Link de YouTube',
      description: 'Canal oficial de YouTube',
      submittedBy: '3',
      submittedByName: 'María García',
      contentUrl: 'https://youtube.com/@ejemplo',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<ApprovalModel> get _filteredApprovals {
    return _approvals.where((approval) {
      final matchesType =
          _selectedTypeFilter == 'all' || approval.type == _selectedTypeFilter;
      return matchesType && !approval.isApproved;
    }).toList();
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'cover':
        return AppColors.info;
      case 'link':
        return AppColors.warning;
      case 'event':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'cover':
        return Icons.image;
      case 'link':
        return Icons.link;
      case 'event':
        return Icons.event;
      default:
        return Icons.pending_actions;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'cover':
        return 'Carátula';
      case 'link':
        return 'Link';
      case 'event':
        return 'Evento';
      default:
        return type;
    }
  }

  void _showApprovalDetail(ApprovalModel approval) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(approval.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(approval.type),
                      color: _getTypeColor(approval.type),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          approval.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              approval.submittedByName,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(approval.submittedAt),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Descripción',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                approval.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Contenido según tipo
              if (approval.type == 'cover' && approval.imageUrl != null) ...[
                const Text(
                  'Vista previa',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 64,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ),
              ] else if (approval.type == 'link' &&
                  approval.contentUrl != null) ...[
                const Text(
                  'Enlace',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          approval.contentUrl!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Acciones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _rejectApproval(approval);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _approveApproval(approval);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _approveApproval(ApprovalModel approval) {
    setState(() {
      final index = _approvals.indexWhere((a) => a.id == approval.id);
      _approvals[index] = approval.copyWith(
        isApproved: true,
        reviewedBy: 'Admin',
        reviewedAt: DateTime.now(),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getTypeLabel(approval.type)} aprobado correctamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectApproval(ApprovalModel approval) {
    setState(() {
      _approvals.removeWhere((a) => a.id == approval.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getTypeLabel(approval.type)} rechazado'),
        backgroundColor: AppColors.error,
      ),
    );
  }

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
                      'Aprobaciones Pendientes',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_filteredApprovals.length} elementos pendientes de revisión',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _selectedTypeFilter,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Todos los tipos'),
                    ),
                    DropdownMenuItem(value: 'cover', child: Text('Carátulas')),
                    DropdownMenuItem(value: 'link', child: Text('Links')),
                    DropdownMenuItem(value: 'event', child: Text('Eventos')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTypeFilter = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Lista de aprobaciones
        Expanded(
          child: _filteredApprovals.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: AppColors.success,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay aprobaciones pendientes',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Todas las solicitudes han sido revisadas',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filteredApprovals.length,
                  itemBuilder: (context, index) {
                    final approval = _filteredApprovals[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceLight),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getTypeColor(
                              approval.type,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getTypeIcon(approval.type),
                            color: _getTypeColor(approval.type),
                            size: 28,
                          ),
                        ),
                        title: Text(
                          approval.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              approval.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(
                                      approval.type,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getTypeLabel(approval.type),
                                    style: TextStyle(
                                      color: _getTypeColor(approval.type),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  approval.submittedByName,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getTimeAgo(approval.submittedAt),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: AppColors.info,
                              ),
                              onPressed: () => _showApprovalDetail(approval),
                              tooltip: 'Ver detalles',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.error,
                              ),
                              onPressed: () => _rejectApproval(approval),
                              tooltip: 'Rechazar',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: AppColors.success,
                              ),
                              onPressed: () => _approveApproval(approval),
                              tooltip: 'Aprobar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }
}
