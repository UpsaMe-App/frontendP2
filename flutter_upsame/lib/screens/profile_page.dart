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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMyPosts();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final userData = await ApiService.getMe();
      setState(() {
        _userData = userData;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMyPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await ApiService.getMyPosts();
      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar posts: $e'),
          backgroundColor: Colors.red,
        ),
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
        title: Text(
          '¿Cerrar sesión?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: GoogleFonts.poppins(),
        ),
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
            child: Text(
              'Cerrar sesión',
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

  /// CARD DE INFORMACIÓN (Carrera, Semestre, Teléfono)
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? bgColor,
    Color? iconColor,
    Color? labelColor,
    Color? valueColor,
  }) {
    // Estilo tipo “glass” sobre el degradado
    final Color _bg = bgColor ?? Colors.white.withOpacity(0.10);
    final Color _icon = iconColor ?? Colors.white;
    final Color _label = labelColor ?? Colors.white70;
    final Color _value = valueColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: _icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 11, color: _label),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _value,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header expandido (avatar grande + nombre + correo)
  Widget _buildExpandedHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white,
          backgroundImage: _userData?['profilePhotoUrl'] != null
              ? NetworkImage(
                  '${ApiService.baseUrl}${_userData!['profilePhotoUrl']}',
                )
              : null,
          child: _userData?['profilePhotoUrl'] == null
              ? const Icon(Icons.person, size: 48, color: Color(0xFF66B2A8))
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          _userData?['fullName'] ?? 'Usuario',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _userData?['email'] ?? '',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Header colapsado (avatar chico + nombre en la barra)
  Widget _buildCollapsedHeader() {
    return Padding(
      // para que no choque con el back y logout
      padding: const EdgeInsets.symmetric(horizontal: 72.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white24,
            backgroundImage: _userData?['profilePhotoUrl'] != null
                ? NetworkImage(
                    '${ApiService.baseUrl}${_userData!['profilePhotoUrl']}',
                  )
                : null,
            child: _userData?['profilePhotoUrl'] == null
                ? const Icon(Icons.person, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _userData?['fullName'] ?? 'Usuario',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  /// SLIVER APP BAR (header con animación)
                  SliverAppBar(
                    backgroundColor: const Color(0xFF357067),
                    elevation: 0,
                    expandedHeight: _expandedHeight,
                    floating: false,
                    snap: false,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: _logout,
                        tooltip: 'Cerrar sesión',
                      ),
                    ],
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final double currentHeight = constraints.maxHeight;
                        // cuando la altura está cerca de la toolbar, consideramos colapsado
                        final bool isCollapsed =
                            currentHeight <= kToolbarHeight + 40;

                        return Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF66B2A8), Color(0xFF4A8B82)],
                            ),
                          ),
                          child: SafeArea(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: isCollapsed
                                    ? _buildCollapsedHeader()
                                    : _buildExpandedHeader(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// SECCIÓN BAJO EL HEADER (cards + botón + contador)
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF4A8B82), Color(0xFF4A8B82)],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  value:
                                      _userData?['semester']?.toString() ??
                                      'N/A',
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
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_userData != null) {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/edit-profile',
                                    arguments: _userData,
                                  );
                                  if (result == true) {
                                    _loadUserData();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF66B2A8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Editar perfil',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              '${_myPosts.length} publicación${_myPosts.length != 1 ? 'es' : ''}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  /// CALENDLY WIDGET
                  if (_userData?['calendlyUrl'] != null &&
                      _userData!['calendlyUrl'].isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agenda una cita',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF357067),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: SizedBox(
                                width: 180,
                                child: Card(
                                  color: const Color(0xFFF6F0FB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final url =
                                            _userData!['calendlyUrl'] as String;
                                        try {
                                          final uri = Uri.tryParse(url);
                                          if (uri != null) {
                                            await launchUrl(
                                              uri,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          } else {
                                            throw 'URL inválida';
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'No se pudo abrir Calendly: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF66B2A8,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'Abrir Calendly',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// POSTS
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_myPosts.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.post_add,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tienes publicaciones',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primera publicación',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return PostCard(
                          post: _myPosts[index],
                          currentUserId: widget.userId,
                          onDeleted: _loadMyPosts,
                          onUpdated: _loadMyPosts,
                        );
                      }, childCount: _myPosts.length),
                    ),
                ],
              ),
      ),
    );
  }
}
