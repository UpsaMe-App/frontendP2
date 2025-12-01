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
  final Color _lightGreen = const Color(0xFF4CAF50);
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

  Future<void> _navigateToPost(MyReplyDto reply) async {
    try {
      // 🔥 Obtener el post completo del API
      final fullPost = await ApiService.getPostById(reply.postId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostDetailPage(post: fullPost)),
      );
    } catch (e) {
      if (!mounted) return;

      // Si falla, usar datos básicos como fallback
      final post = Post(
        id: reply.postId,
        title: reply.postTitle ?? 'Post',
        content: reply.postContentPreview ?? '',
        role: 2,
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
        imageUrl: reply.imageUrl,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar post completo: $e'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          content: const Text('Respuesta eliminada'),
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
                // ===== HEADER CON AUTOR DEL POST =====
                Row(
                  children: [
                    // Avatar del autor del POST
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _primaryGreen.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryGreen.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _primaryGreen.withOpacity(0.1),
                                          _lightGreen.withOpacity(0.2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: _primaryGreen,
                                      size: 22,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _primaryGreen.withOpacity(0.1),
                                      _lightGreen.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: _primaryGreen,
                                  size: 22,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info del autor (nombre + tiempo)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.postAuthorFullName ?? 'Usuario',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(reply.createdAt),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Botón eliminar premium
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showDeleteDialog(reply),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ===== CONTENIDO DEL POST =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Text(
                    reply.postTitle ?? 'Sin título',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // ===== TU RESPUESTA (PREMIUM STYLE) =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _primaryGreen.withOpacity(0.05),
                        _lightGreen.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _primaryGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con "Tu respuesta"
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.reply_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tu respuesta',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Tu respuesta con avatar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tu avatar pequeño
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _primaryGreen.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryGreen.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: reply.replyAuthorPhotoUrl.isNotEmpty
                                  ? Image.network(
                                      ApiService.getFullImageUrl(
                                        reply.replyAuthorPhotoUrl,
                                      ),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _primaryGreen.withOpacity(
                                                      0.2,
                                                    ),
                                                    _lightGreen.withOpacity(
                                                      0.3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.person_rounded,
                                                color: _primaryGreen,
                                                size: 18,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _primaryGreen.withOpacity(0.2),
                                            _lightGreen.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: _primaryGreen,
                                        size: 18,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Contenido de tu respuesta
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                reply.content,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== MATERIA (PREMIUM BADGE) =====
                if (reply.subjectName != null &&
                    reply.subjectName!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryGreen.withOpacity(0.9), _lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryGreen.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            reply.subjectName!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
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
