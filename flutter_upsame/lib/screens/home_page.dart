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

  // Paleta UPSA vibes (verde, no turquesa)
  final Color _greenDark = const Color(0xFF2E7D32);
  final Color _green = const Color(0xFF388E3C);
  final Color _greenLight = const Color.fromARGB(255, 88, 192, 91);

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

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required int? roleValue,
  }) {
    final bool isSelected = _selectedRole == roleValue;
    return GestureDetector(
      onTap: () => _filterByRole(roleValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? _greenDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _greenDark : _greenLight,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(isSelected ? 0.28 : 0.12),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : _greenDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : _greenDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Todos',
              icon: Icons.all_inclusive,
              roleValue: null,
            ),
            _buildFilterChip(
              label: 'Ayudantes',
              icon: Icons.school,
              roleValue: 1,
            ),
            _buildFilterChip(
              label: 'Estudiantes',
              icon: Icons.person,
              roleValue: 2,
            ),
            _buildFilterChip(
              label: 'Comentarios',
              icon: Icons.comment,
              roleValue: 3,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenLight.withOpacity(0.18),
      appBar: AppBar(
        title: Text(
          'UpsaMe',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _greenDark,
                _green,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFiltersBar(),
        ),
      ),
      body: RefreshIndicator(
        color: _greenDark,
        onRefresh: _loadPosts,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: _greenDark,
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
                            color: _greenLight.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: _greenDark,
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
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 80, left: 4, right: 4),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 260 + index * 35),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 14),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: _green.withOpacity(0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: PostCard(
                            post: post,
                            currentUserId: widget.userId,
                            onDeleted: _loadPosts,
                            onUpdated: _loadPosts,
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _greenDark.withOpacity(0.35),
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
          backgroundColor: _greenDark,
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
