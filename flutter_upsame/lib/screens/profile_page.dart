import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/token_manager.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Post> _myPosts = [];
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  final double _expandedHeight = 260;

  final Color greenDark = const Color(0xFF2E7D32);
  final Color green = const Color(0xFF388E3C);
  final Color greenLight = const Color(0xFFA5D6A7);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMyPosts();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingProfile = true);

    try {
      final userData = await ApiService.getMe();
      setState(() {
        _userData = userData;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() => _isLoadingProfile = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: $e')),
      );
    }
  }

  Future<void> _loadMyPosts() async {
    setState(() => _isLoading = true);

    try {
      final posts = await ApiService.getMyPosts();
      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar posts: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([_loadUserData(), _loadMyPosts()]);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Cerrar sesión?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro que deseas cerrar sesión?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              TokenManager.stopTokenRefresh();
              ApiService.clearTokens();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text('Cerrar sesión',
                style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // CARD INFO ESTILO ELEGANTE
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: green.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white70)),
                const SizedBox(height: 2),
                Text(value,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEADER EXPANDIDO
  Widget _buildExpandedHeader() {
    return Column(
      children: [
        const SizedBox(height: 12),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white70,
          backgroundImage: _userData?['profilePhotoUrl'] != null
              ? NetworkImage('${ApiService.baseUrl}${_userData!['profilePhotoUrl']}')
              : null,
          child: _userData?['profilePhotoUrl'] == null
              ? Icon(Icons.person, size: 52, color: greenDark)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          _userData?['fullName'] ?? 'Usuario',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userData?['email'] ?? '',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  // HEADER COLAPSADO
  Widget _buildCollapsedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white30,
          backgroundImage: _userData?['profilePhotoUrl'] != null
              ? NetworkImage('${ApiService.baseUrl}${_userData!['profilePhotoUrl']}')
              : null,
          child: _userData?['profilePhotoUrl'] == null
              ? Icon(Icons.person, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          _userData?['fullName'] ?? 'Usuario',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  // ANIMACIÓN PARA POSTS
  Widget _animatedPostCard(Post post, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + index * 40),
      curve: Curves.easeOutCubic,
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
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: green.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: PostCard(
          post: post,
          currentUserId: widget.userId,
          onDeleted: _loadMyPosts,
          onUpdated: _loadMyPosts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenLight.withOpacity(0.20),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: greenDark,
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // HEADER SLIVER
                  SliverAppBar(
                    backgroundColor: greenDark,
                    elevation: 0,
                    expandedHeight: _expandedHeight,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ],
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final collapsed =
                            constraints.maxHeight <= kToolbarHeight + 40;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                greenDark,
                                green,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: SafeArea(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child:
                                    collapsed ? _buildCollapsedHeader() : _buildExpandedHeader(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // INFO CARDS
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [green, greenDark],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.school,
                                  label: 'Carrera',
                                  value: _userData?['career'] ?? 'N/A',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.calendar_today,
                                  label: 'Semestre',
                                  value: _userData?['semester']?.toString() ?? 'N/A',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.phone,
                                  label: 'Teléfono',
                                  value: _userData?['phone'] ?? 'N/A',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(context, '/edit-profile',
                                  arguments: _userData);
                              if (result == true) _loadUserData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: greenDark,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text('Editar perfil',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_myPosts.length} publicación${_myPosts.length != 1 ? "es" : ""}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // POSTS
                  if (_isLoading)
                    const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()))
                  else if (_myPosts.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No tienes publicaciones',
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _animatedPostCard(_myPosts[index], index),
                        childCount: _myPosts.length,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
