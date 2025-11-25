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

  bool get isOwner {
    final result = currentUserId != null && post.userId == currentUserId;
    // Debug: imprimir para ver qué está pasando
    print('PostCard: currentUserId=$currentUserId, post.userId=${post.userId}, isOwner=$result');
    return result;
  }

  // Paleta verde UPSA
  Color get _greenDark => const Color(0xFF2E7D32);
  Color get _green => const Color(0xFF388E3C);
  Color get _greenLight => const Color(0xFFA5D6A7);

  Color _getRoleColor() {
    // Todos verdes, pero con tonos distintos por rol
    switch (post.role) {
      case 1: // Ayudante
        return _greenDark;
      case 2: // Estudiante
        return _green;
      case 3: // Comentario
        return _greenLight;
      default:
        return _green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();

    return Card(
      margin: EdgeInsets.zero, // el margen lo maneja el contenedor padre
      elevation: 0, // sombra la pone el wrapper en Home/Profile
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: roleColor.withOpacity(0.35),
          width: 1.4,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/post-detail', arguments: post);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: Avatar + Nombre + Rol + Menú
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      radius: 22,
                      backgroundColor: roleColor.withOpacity(0.12),
                      backgroundImage: post.user?.photoUrl != null &&
                              post.user!.photoUrl.isNotEmpty
                          ? NetworkImage(
                              '${ApiService.baseUrl}${post.user!.photoUrl}',
                            )
                          : null,
                      child: (post.user?.photoUrl == null ||
                              post.user!.photoUrl.isEmpty)
                          ? Icon(Icons.person, color: roleColor, size: 22)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre
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
                              fontWeight: FontWeight.w600,
                              fontSize: 15.5,
                              color: _greenDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Badge de rol
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: roleColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                post.roleText,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (post.subject != null) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  post.subject!.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menú si es el dueño
                  if (isOwner)
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editPost(context);
                        } else if (value == 'delete') {
                          _deletePost(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: _greenDark),
                              const SizedBox(width: 8),
                              Text(
                                'Editar',
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // TÍTULO
              Text(
                post.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _greenDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // CONTENIDO
              Text(
                post.content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // INFO ADICIONAL PARA AYUDANTES
              if (post.role == 1 && post.maxCapacity != null) ...[
                Row(
                  children: [
                    Icon(Icons.people,
                        size: 16, color: _greenDark.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      'Capacidad: ${post.capacity ?? 0}/${post.maxCapacity}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (post.calendlyUrl != null &&
                        post.calendlyUrl!.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: _greenDark.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Calendly disponible',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // FECHA
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
    Navigator.pushNamed(context, '/edit-post', arguments: post).then((result) {
      // Only refresh if the edit was successful (result == true)
      if (result == true && onUpdated != null) onUpdated!();
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
              print('============ DELETE POST ============');
              print('Confirmando eliminación del post: ${post.id}');
              Navigator.pop(context);
              try {
                print('Llamando a ApiService.deletePost...');
                await ApiService.deletePost(post.id);
                print('Post eliminado con éxito');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Post eliminado exitosamente'),
                      backgroundColor: _greenDark,
                    ),
                  );
                  print('Llamando a onDeleted callback...');
                  if (onDeleted != null) {
                    onDeleted!();
                    print('onDeleted callback ejecutado');
                  } else {
                    print('WARNING: onDeleted callback es null');
                  }
                }
              } catch (e) {
                print('ERROR al eliminar post: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
              print('=====================================');
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
