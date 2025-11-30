import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/calendly_inline_widget.dart';
import '../widgets/safe_image_widget.dart';

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
  Map<String, dynamic>? _userData; // Current user data
  File? _replyImage;
  Uint8List? _replyImageBytes;
  String? _replyImageFileName;
  final ImagePicker _picker = ImagePicker();

  final Color greenDark = const Color(0xFF2E7D32);
  final Color green = const Color(0xFF4CAF50);
  final Color greenLight = const Color(0xFFA5D6A7);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (widget.post.role == 2 || widget.post.role == 3) {
      _loadReplies();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.getMe();
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      print('Error loading user data: $e');
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
      await ApiService.createReply(
        postId: widget.post.id,
        content: _replyController.text.trim(),
        image: kIsWeb ? null : _replyImage,
        imageBytes: _replyImageBytes,
        imageFileName: _replyImageFileName,
      );

      _replyController.clear();
      setState(() {
        _replyImage = null;
        _replyImageBytes = null;
        _replyImageFileName = null;
      });

      // Reload replies to get complete user data
      await _loadReplies();

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Respuesta enviada')));
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (!kIsWeb) {
            _replyImage = File(image.path);
          }
          _replyImageBytes = bytes;
          _replyImageFileName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidCalendlyUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    // Solo aceptamos calendly “real”
    return url.startsWith('https://calendly.com/');
  }

  Widget _buildReplyCard(Reply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: greenLight, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: green.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: greenLight.withOpacity(0.4),
                backgroundImage: reply.user != null && reply.user!.photoUrl.isNotEmpty
                    ? NetworkImage(
                        ApiService.getFullImageUrl(reply.user!.photoUrl),
                      )
                    : null,
                child: reply.user == null || reply.user!.photoUrl.isEmpty
                    ? Icon(Icons.person, size: 18, color: greenDark)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.user?.displayName ?? 'Usuario',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: greenDark,
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
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.45,
            ),
          ),
          if (reply.imageUrl != null && reply.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SafeImageWidget(
              url: ApiService.getFullImageUrl(reply.imageUrl),
              fit: BoxFit.contain,
              borderRadius: 12,
              maxWidth: 600,
              optimizeImage: false,
            ),
          ],
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

  void _handlePostUpdated() {
    setState(() {
      // Refresh data or UI as needed
    });
  }

  void _handlePostDeleted() {
    Navigator.pop(context, true);
  }

  bool get _isOwner {
    return _userData != null && widget.post.userId == _userData!['id'];
  }

  void _editPost() {
    Navigator.pushNamed(context, '/edit-post', arguments: widget.post).then((
      result,
    ) {
      if (result == true) {
        _handlePostUpdated();
      }
    });
  }

  void _deletePost() {
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
                await ApiService.deletePost(widget.post.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Post eliminado exitosamente'),
                      backgroundColor: greenDark,
                    ),
                  );
                  _handlePostDeleted();
                }
              } catch (e) {
                if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo sólido blanco
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detalle de Publicación',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: greenDark,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: _isOwner
            ? [
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editPost();
                    } else if (value == 'delete') {
                      _deletePost();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: greenDark),
                          const SizedBox(width: 8),
                          Text('Editar', style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Eliminar',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: greenLight, width: 1.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/public-profile',
                                arguments: widget.post.userId,
                              );
                            },

                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: greenLight.withOpacity(0.4),
                              backgroundImage:
                                  widget.post.user?.photoUrl != null &&
                                      widget.post.user!.photoUrl.isNotEmpty
                                  ? NetworkImage(
                                      ApiService.getFullImageUrl(
                                        widget.post.user!.photoUrl,
                                      ),
                                    )
                                  : null,
                              child:
                                  widget.post.user?.photoUrl == null ||
                                      widget.post.user!.photoUrl.isEmpty
                                  ? Icon(Icons.person, color: greenDark)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.user?.fullName ?? 'Usuario',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: greenDark,
                                  ),
                                ),
                                Text(
                                  widget.post.roleText,
                                  style: GoogleFonts.poppins(
                                    color: green,
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

                    const SizedBox(height: 12),

                    // CONTENIDO POST
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: greenLight, width: 1.3),
                        boxShadow: [
                          BoxShadow(
                            color: green.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.title,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: greenDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.post.content,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                          if (widget.post.imageUrl != null &&
                              widget.post.imageUrl!.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            SafeImageWidget(
                              url: ApiService.getFullImageUrl(
                                widget.post.imageUrl,
                              ),
                              fit: BoxFit.contain,
                              borderRadius: 12,
                              optimizeImage: false,
                            ),
                          ],
                          const SizedBox(height: 20),

                          if (widget.post.subject != null) ...[
                            Row(
                              children: [
                                Icon(Icons.book, size: 20, color: greenDark),
                                const SizedBox(width: 8),
                                Text(
                                  'Materia: ${widget.post.subject!.name}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: greenDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],

                          if (widget.post.role == 1 &&
                              widget.post.maxCapacity != null)
                            Row(
                              children: [
                                Icon(Icons.people, size: 20, color: greenDark),
                                const SizedBox(width: 8),
                                Text(
                                  'Capacidad: ${widget.post.capacity ?? 0}/${widget.post.maxCapacity}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: greenDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // CALENDLY SOLO SI ES CALENDLY REAL
                    if (_isValidCalendlyUrl(widget.post.calendlyUrl)) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Agenda una cita',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: greenDark,
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

                    // REPLIES
                    if (widget.post.role == 2 || widget.post.role == 3) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Respuestas',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: greenDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                                color: Colors.grey[700],
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

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // INPUT RESPUESTA
          if (widget.post.role == 2 || widget.post.role == 3)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: greenLight, width: 1.2)),
                boxShadow: [
                  BoxShadow(
                    color: green.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    if (_replyImage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: kIsWeb && _replyImageBytes != null
                                  ? Image.memory(
                                      _replyImageBytes!,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.file(
                                      _replyImage!,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _replyImage = null;
                                    _replyImageBytes = null;
                                    _replyImageFileName = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        // Only show image picker for Student posts (role == 2)
                        if (widget.post.role == 2)
                          IconButton(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image, color: greenDark),
                          ),
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
                              fillColor: greenLight.withOpacity(0.25),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: greenLight,
                                  width: 1.2,
                                ),
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
                          color: greenDark,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
