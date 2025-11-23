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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'UpsaMe',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<int?>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtrar por tipo',
              onSelected: _filterByRole,
              itemBuilder: (context) => [
                PopupMenuItem<int?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.all_inclusive,
                        color: _selectedRole == null ? const Color(0xFF66B2A8) : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Todos',
                        style: GoogleFonts.poppins(
                          fontWeight: _selectedRole == null ? FontWeight.bold : FontWeight.normal,
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
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ayudantes',
                        style: GoogleFonts.poppins(
                          fontWeight: _selectedRole == 1 ? FontWeight.bold : FontWeight.normal,
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
                        color: _selectedRole == 2 ? const Color(0xFF66B2A8) : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estudiantes',
                        style: GoogleFonts.poppins(
                          fontWeight: _selectedRole == 2 ? FontWeight.bold : FontWeight.normal,
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
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Comentarios',
                        style: GoogleFonts.poppins(
                          fontWeight: _selectedRole == 3 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF66B2A8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay publicaciones',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Sé el primero en publicar!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create-post');
          if (result == true) {
            _loadPosts();
          }
        },
        backgroundColor: const Color(0xFFE85D75),
        icon: const Icon(Icons.add),
        label: Text(
          'Publicar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
