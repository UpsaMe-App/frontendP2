import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import '../utils/token_manager.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Post> _myPosts = [];
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isLoadingProfile = true;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> _refreshData() async {
    await Future.wait([
      _loadUserData(),
      _loadMyPosts(),
    ]);
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF66B2A8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Header section with user info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF66B2A8),
                    Color(0xFF4A8B82),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Avatar with edit button
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
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
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _userData?['profilePhotoUrl'] != null
                              ? NetworkImage(
                                  '${ApiService.baseUrl}${_userData!['profilePhotoUrl']}',
                                )
                              : null,
                          child: _userData?['profilePhotoUrl'] == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF66B2A8),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
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
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF66B2A8),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF66B2A8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // User name
                  Text(
                    _userData?['fullName'] ?? 'Usuario',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // User email
                  Text(
                    _userData?['email'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User info cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoCard(
                        icon: Icons.school,
                        label: 'Carrera',
                        value: _userData?['career'] ?? 'N/A',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        label: 'Semestre',
                        value: _userData?['semester']?.toString() ?? 'N/A',
                      ),
                      if (_userData?['phone'] != null) ...[
                        const SizedBox(width: 12),
                        _buildInfoCard(
                          icon: Icons.phone,
                          label: 'Teléfono',
                          value: _userData!['phone'],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Edit profile button
                  ElevatedButton.icon(
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
                    icon: const Icon(Icons.edit),
                    label: Text(
                      'Editar Perfil',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF66B2A8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Posts count
                  Text(
                    '${_myPosts.length} publicación${_myPosts.length != 1 ? 'es' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Posts list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _myPosts.isEmpty
                      ? Center(
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
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: _myPosts.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: _myPosts[index],
                              currentUserId: widget.userId,
                              onDeleted: _loadMyPosts,
                              onUpdated: _loadMyPosts,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
