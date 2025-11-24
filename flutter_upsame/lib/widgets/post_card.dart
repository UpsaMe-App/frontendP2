import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String? currentUserId;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  const PostCard({
    super.key,
    required this.post,
    this.currentUserId,
    this.onDeleted,
    this.onUpdated,
  });

  bool get isOwner => currentUserId != null && post.userId == currentUserId;

  Color _getRoleColor() {
    switch (post.role) {
      case 1:
        return const Color(0xFFE85D75); // Ayudante - Rojo
      case 2:
        return const Color(0xFF357067); // Estudiante - Verde oficial
      case 3:
        return const Color(0xFF9B7EBD); // Comentario - Morado
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getRoleColor().withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () {
          // Navegar al detalle del post
          Navigator.pushNamed(context, '/post-detail', arguments: post);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con usuario y rol
              Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () {
                      if (post.user != null) {
                        Navigator.pushNamed(
                          context,
                          '/public-profile',
                          arguments: post.user!.id,
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: _getRoleColor().withOpacity(0.2),
                      backgroundImage:
                          post.user?.photoUrl != null &&
                              post.user!.photoUrl.isNotEmpty
                          ? NetworkImage(
                              '${ApiService.baseUrl}${post.user!.photoUrl}',
                            )
                          : null,
                      child:
                          post.user?.photoUrl == null ||
                              post.user!.photoUrl.isEmpty
                          ? Icon(Icons.person, color: _getRoleColor())
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (post.user != null) {
                              Navigator.pushNamed(
                                context,
                                '/public-profile',
                                arguments: post.user!.id,
                              );
                            }
                          },
                          child: Text(
                            post.user?.displayName ?? 'Usuario',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post.roleText,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (post.subject != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                post.subject!.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Opciones si es el dueño
                  if (isOwner)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editPost(context);
                        } else if (value == 'delete') {
                          _deletePost(context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Título
              Text(
                post.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Contenido
              Text(
                post.content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Info adicional para ayudantes
              if (post.role == 1 && post.maxCapacity != null) ...[
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Capacidad: ${post.capacity ?? 0}/${post.maxCapacity}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (post.calendlyUrl != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Calendly disponible',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Fecha
              Text(
                _formatDate(post.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  void _editPost(BuildContext context) {
    Navigator.pushNamed(context, '/edit-post', arguments: post).then((_) {
      if (onUpdated != null) onUpdated!();
    });
  }

  void _deletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¿Eliminar post?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.deletePost(post.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  if (onDeleted != null) onDeleted!();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
