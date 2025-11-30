import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _posts = []; // lista que se muestra (filtrada)
  List<Post> _allPosts = []; // lista completa sin filtro
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int?
  _selectedRole; // null = todos, 1 = ayudantes, 2 = estudiantes, 3 = comentarios
  final ScrollController _scrollController = ScrollController();

  final Color _greenDark = const Color(0xFF2E7D32);
  final Color _green = const Color(0xFF388E3C);
  final Color _greenLight = const Color.fromARGB(255, 88, 192, 91);

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      // Traemos la primera página
      final posts = await ApiService.getPosts(page: _currentPage, pageSize: 10);

      if (!mounted) return;

      setState(() {
        _allPosts = posts;
        _hasMore = posts.length >= 10; // Si recibió menos de 10, no hay más
      });

      // Aplicamos el filtro actual
      _applyFilter();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar posts: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final newPosts = await ApiService.getPosts(
        page: _currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      setState(() {
        _allPosts.addAll(newPosts);
        _hasMore = newPosts.length >= 10;
        _isLoadingMore = false;
      });

      _applyFilter();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Revertir el incremento si falló
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar más posts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedRole == null) {
        // "Todos": mostramos todo
        _posts = List<Post>.from(_allPosts);
      } else {
        // Filtramos según el rol
        _posts = _allPosts.where((post) => post.role == _selectedRole).toList();
      }
    });
  }

  void _filterByRole(int? role) {
    // Si tocan el mismo filtro de nuevo, reseteamos a "Todos"
    if (_selectedRole == role) {
      _selectedRole = null;
    } else {
      _selectedRole = role;
    }

    _applyFilter();
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
            Icon(icon, size: 18, color: isSelected ? Colors.white : _greenDark),
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
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
                  ? Center(child: CircularProgressIndicator(color: _greenDark))
                  : _posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: _greenDark,
                          ),
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
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: _posts.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _posts.length) {
                          // Indicador de carga al final
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _greenDark,
                              ),
                            ),
                          );
                        }

                        final post = _posts[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 250 + index * 40),
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
                              horizontal: 16,
                              vertical: 10,
                            ),
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
