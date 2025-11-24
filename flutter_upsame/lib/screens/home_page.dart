import 'dart:ui';
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
  int? _selectedRole;

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          color: isSelected ? _greenDark : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _greenDark : _greenLight,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(isSelected ? 0.30 : 0.10),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
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

  Widget _buildFiltersBarFloating() {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _greenLight.withOpacity(0.5),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _green.withOpacity(0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenLight.withOpacity(0.14),
      appBar: AppBar(
        title: Text(
          'UpsaMe',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: _greenDark,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: _greenDark,
            onRefresh: _loadPosts,
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: _greenDark,
                      ),
                    )
                  : _posts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 64, color: _greenDark),
                              const SizedBox(height: 20),
                              Text(
                                "No hay publicaciones",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                  milliseconds: 250 + index * 40),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 18),
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _green.withOpacity(0.16),
                                      blurRadius: 14,
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
          ),

          _buildFiltersBarFloating(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _greenDark,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: Text(
          "Publicar",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create-post');
          if (result == true) _loadPosts();
        },
      ),
    );
  }
}
