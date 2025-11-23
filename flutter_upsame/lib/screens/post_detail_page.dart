import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/calendly_inline_widget.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  Color _getRoleColor() {
    switch (post.role) {
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
      body: SingleChildScrollView(
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
                      if (post.user != null) {
                        Navigator.pushNamed(
                          context,
                          '/public-profile',
                          arguments: post.user!.id,
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 24,
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
                        Text(
                          post.user?.fullName ?? 'Usuario',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          post.roleText,
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
                    post.title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.content,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (post.subject != null) ...[
                    Row(
                      children: [
                        Icon(Icons.book, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Materia: ${post.subject!.name}',
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
                  if (post.role == 1 && post.maxCapacity != null)
                    Row(
                      children: [
                        Icon(Icons.people, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Capacidad: ${post.capacity ?? 0}/${post.maxCapacity}',
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
            if (post.calendlyUrl != null && post.calendlyUrl!.isNotEmpty) ...[
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
                  calendlyUrl: post.calendlyUrl!,
                  height: 700,
                  embedInline: true,
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
