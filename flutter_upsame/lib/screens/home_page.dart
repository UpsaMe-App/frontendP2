import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({
    super.key,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _posts = [];
  bool _isLoading = false;
  int? _selectedRole; // null = todos, 1 = ayudante, 2 = estudiante, 3 = comentario

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await ApiService.getPosts(role: _selectedRole);
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
      print('Posts cargados: ${posts.length}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading posts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterByRole(int? role) {
    setState(() {
      _selectedRole = role;
    });
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'UpsaMe',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<int?>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.filter_list, size: 20),
              ),
              tooltip: 'Filtrar por tipo',
              onSelected: _filterByRole,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<int?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.all_inclusive,
                        color: _selectedRole == null ? const Color(0xFF357067) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Todos',
                        style: GoogleFonts.poppins(
                          fontWeight: _selectedRole == null ? FontWeight.bold : FontWeight.normal,
                          color: _selectedRole == null ? const Color(0xFF357067) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<int?>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: _selectedRole == 1 ? const Color(0xFFE85D75) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Ayudantes',
                        style: GoogleFonts.poppins(
                          fontWeight: _selectedRole == 1 ? FontWeight.bold : FontWeight.normal,
                          color: _selectedRole == 1 ? const Color(0xFFE85D75) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<int?>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: _selectedRole == 2 ? const Color(0xFF357067) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Estudiantes',
                        style: GoogleFonts.poppins(
                          fontWeight: _selectedRole == 2 ? FontWeight.bold : FontWeight.normal,
                          color: _selectedRole == 2 ? const Color(0xFF357067) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<int?>(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment,
                        color: _selectedRole == 3 ? const Color(0xFF9B7EBD) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Comentarios',
                        style: GoogleFonts.poppins(
                          fontWeight: _selectedRole == 3 ? FontWeight.bold : FontWeight.normal,
                          color: _selectedRole == 3 ? const Color(0xFF9B7EBD) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF357067),
                Color(0xFF2F6159),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF357067),
        onRefresh: _loadPosts,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF357067),
                  strokeWidth: 3,
                ),
              )
            : _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF357067).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Color(0xFF357067),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No hay publicaciones',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Sé el primero en publicar!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        post: _posts[index],
                        currentUserId: widget.userId,
                        onDeleted: _loadPosts,
                        onUpdated: _loadPosts,
                      );
                    },
                  ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE85D75).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/create-post');
            if (result == true) {
              _loadPosts();
            }
          },
          backgroundColor: const Color(0xFFE85D75),
          elevation: 0,
          icon: const Icon(Icons.add, size: 24),
          label: Text(
            'Publicar',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
