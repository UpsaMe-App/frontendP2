import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/calendly_inline_widget.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _replyController = TextEditingController();
  List<Reply> _replies = [];
  bool _isLoadingReplies = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.post.role == 3) {
      _loadReplies();
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    setState(() => _isLoadingReplies = true);
    try {
      final replies = await ApiService.getReplies(widget.post.id);
      setState(() {
        _replies = replies;
        _isLoadingReplies = false;
      });
    } catch (e) {
      setState(() => _isLoadingReplies = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar respuestas: $e')),
        );
      }
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final newReply = await ApiService.createReply(
        postId: widget.post.id,
        content: _replyController.text.trim(),
      );
      
      setState(() {
        _replies.add(newReply);
        _replyController.clear();
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respuesta enviada')),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar respuesta: $e')),
        );
      }
    }
  }

  Color _getRoleColor() {
    switch (widget.post.role) {
      case 1:
        return const Color(0xFFE85D75); // Ayudante - Rojo
      case 2:
        return const Color(0xFF66B2A8); // Estudiante - Verde
      case 3:
        return const Color(0xFF9B7EBD); // Comentario - Morado
      default:
        return Colors.grey;
    }
  }

  Widget _buildReplyCard(Reply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _getRoleColor().withOpacity(0.2),
                backgroundImage: reply.user?.photoUrl != null &&
                        reply.user!.photoUrl.isNotEmpty
                    ? NetworkImage(
                        '${ApiService.baseUrl}${reply.user!.photoUrl}',
                      )
                    : null,
                child: reply.user?.photoUrl == null ||
                        reply.user!.photoUrl.isEmpty
                    ? Icon(Icons.person,
                        size: 16, color: _getRoleColor())
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.user?.displayName ?? 'Usuario',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(reply.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reply.content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? "s" : ""}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? "s" : ""}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? "s" : ""}';
    } else {
      return 'justo ahora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Detalle de Publicación',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: _getRoleColor(),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user info
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.post.user != null) {
                              Navigator.pushNamed(
                                context,
                                '/public-profile',
                                arguments: widget.post.user!.id,
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: _getRoleColor().withOpacity(0.2),
                            backgroundImage: widget.post.user?.photoUrl !=
                                        null &&
                                    widget.post.user!.photoUrl.isNotEmpty
                                ? NetworkImage(
                                    '${ApiService.baseUrl}${widget.post.user!.photoUrl}',
                                  )
                                : null,
                            child: widget.post.user?.photoUrl == null ||
                                    widget.post.user!.photoUrl.isEmpty
                                ? Icon(Icons.person, color: _getRoleColor())
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.user?.fullName ?? 'Usuario',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.post.roleText,
                                style: GoogleFonts.poppins(
                                  color: _getRoleColor(),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Post Content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.post.content,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (widget.post.subject != null) ...[
                          Row(
                            children: [
                              Icon(Icons.book,
                                  size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Materia: ${widget.post.subject!.name}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (widget.post.role == 1 &&
                            widget.post.maxCapacity != null)
                          Row(
                            children: [
                              Icon(Icons.people,
                                  size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Capacidad: ${widget.post.capacity ?? 0}/${widget.post.maxCapacity}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Calendly Widget
                  if (widget.post.calendlyUrl != null &&
                      widget.post.calendlyUrl!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Agenda una cita',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF357067),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CalendlyInlineWidget(
                        calendlyUrl: widget.post.calendlyUrl!,
                        height: 700,
                        embedInline: true,
                      ),
                    ),
                  ],

                  // Replies Section (only for comment posts)
                  if (widget.post.role == 3) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Respuestas',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9B7EBD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Replies List
                    if (_isLoadingReplies)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_replies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No hay respuestas aún. ¡Sé el primero!',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _replies
                              .map((reply) => _buildReplyCard(reply))
                              .toList(),
                        ),
                      ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Reply Input (only for comment posts)
          if (widget.post.role == 3)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        decoration: InputDecoration(
                          hintText: 'Escribe una respuesta...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: const Color(0xFF9B7EBD),
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: _isSubmitting ? null : _submitReply,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
