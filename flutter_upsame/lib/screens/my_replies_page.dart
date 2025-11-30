import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../screens/post_detail_page.dart';

class MyRepliesPage extends StatefulWidget {
  const MyRepliesPage({super.key});

  @override
  State<MyRepliesPage> createState() => _MyRepliesPageState();
}

class _MyRepliesPageState extends State<MyRepliesPage> {
  List<MyReplyDto> _replies = [];
  bool _isLoading = false;

  // Paleta de colores verde
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _lightGreen = const Color(0xFF4CAF50);
  final Color _accentGreen = const Color(0xFF81C784);
  final Color _backgroundGreen = const Color(0xFFE8F5E8);

  @override
  void initState() {
    super.initState();
    _loadMyReplies();
  }

  Future<void> _loadMyReplies() async {
    setState(() => _isLoading = true);

    try {
      final replies = await ApiService.getMyReplies();
      setState(() {
        _replies = replies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar respuestas: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateToPost(MyReplyDto reply) {
    // Crear un objeto Post temporal para navegar a la pantalla de detalle
    final post = Post(
      id: reply.postId,
      title: reply.postTitle ?? 'Post',
      content: reply.postContentPreview ?? '',
      role: 2, // Asumimos que es un post de estudiante
      createdAt: reply.createdAt,
      user: User(
        id: reply.postAuthorId ?? '',
        email: '',
        fullName: reply.postAuthorFullName,
        avatarId: reply.postAuthorAvatarId,
        profilePhotoUrl: reply.postAuthorProfilePhotoUrl,
        semester: 1,
      ),
      subjectName: reply.subjectName,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
    );
  }

  void _showDeleteDialog(MyReplyDto reply) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¿Eliminar respuesta?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro que deseas eliminar esta respuesta? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReply(reply);
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

  Future<void> _deleteReply(MyReplyDto reply) async {
    try {
      await ApiService.deleteReply(reply.replyId, postId: reply.postId);

      setState(() {
        _replies.removeWhere((r) => r.replyId == reply.replyId);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Respuesta eliminada'),
          backgroundColor: _primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar respuesta: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGreen,
      appBar: AppBar(
        title: Text(
          'Mis Respuestas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMyReplies,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _replies.isEmpty
          ? _buildEmptyScreen()
          : _buildRepliesList(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando respuestas...',
            style: GoogleFonts.poppins(
              color: _primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.comment_outlined,
            size: 100,
            color: _primaryGreen.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'No has respondido a ningún post',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus respuestas aparecerán aquí',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesList() {
    return RefreshIndicator(
      onRefresh: _loadMyReplies,
      color: _primaryGreen,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _replies.length,
        itemBuilder: (context, index) {
          final reply = _replies[index];
          return _buildReplyCard(reply);
        },
      ),
    );
  }

  Widget _buildReplyCard(MyReplyDto reply) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToPost(reply),
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar del autor del POST + Nombre + Tiempo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar del AUTOR DEL POST (no mío)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _primaryGreen.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: reply.postAuthorPhotoUrl.isNotEmpty
                            ? Image.network(
                                ApiService.getFullImageUrl(
                                  reply.postAuthorPhotoUrl,
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: _lightGreen.withOpacity(0.2),
                                    child: Icon(
                                      Icons.person,
                                      color: _primaryGreen,
                                      size: 20,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: _lightGreen.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  color: _primaryGreen,
                                  size: 20,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nombre del autor del POST
                    Expanded(
                      child: Text(
                        reply.postAuthorFullName ?? 'Usuario',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tiempo
                    Text(
                      _formatDate(reply.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón eliminar
                    InkWell(
                      onTap: () => _showDeleteDialog(reply),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Título del post
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Text(
                    reply.postTitle ?? 'Sin título',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                // Flecha + MI avatar + MI respuesta
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.subdirectory_arrow_right,
                        color: _primaryGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // MI Avatar
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _primaryGreen.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: reply.replyAuthorPhotoUrl.isNotEmpty
                            ? Image.network(
                                ApiService.getFullImageUrl(
                                  reply.replyAuthorPhotoUrl,
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: _lightGreen.withOpacity(0.2),
                                    child: Icon(
                                      Icons.person,
                                      color: _primaryGreen,
                                      size: 16,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: _lightGreen.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  color: _primaryGreen,
                                  size: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // MI respuesta
                    Expanded(
                      child: Text(
                        reply.content,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Materia si existe
                if (reply.subjectName != null &&
                    reply.subjectName!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.book_outlined, size: 14, color: _primaryGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          reply.subjectName!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
