import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import '../utils/token_manager.dart';
import 'my_replies_page.dart';

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

  final double _expandedHeight = 260; // Reduced to avoid overflow

  // ✨ Premium Color System - Verde Exacto del Usuario
  final Color greenPrimary = const Color(0xFF43A047);      // Verde base (el que mostraste)
  final Color greenSecondary = const Color(0xFF388E3C);    // Verde un poco más oscuro
  final Color greenDark = const Color(0xFF2E7D32);         // Verde oscuro para contraste
  final Color greenAccent = const Color(0xFF66BB6A);       // Verde claro para highlights
  final Color backgroundLight = const Color(0xFFF1F8E4);   // Fondo verdoso muy claro
  final Color textDark = const Color(0xFF1B5E20);          // Verde muy oscuro para texto
  final Color textMuted = const Color(0xFF757575);         // Gris medio

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar perfil: $e')));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar posts: $e')));
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

  // ✨ CARD INFO CON GLASSMORPHISM PREMIUM
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Glassmorphism gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          // Sombra principal
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          // Highlight sutil arriba
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono con gradiente circular
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [greenPrimary, greenSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: greenPrimary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          // Label
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA PREMIUM DE ACCIONES - Diseño Ultra Premium
  Widget _buildProfileActionsCard() {
    const Color softGreen = Color(0xFFE8F5E9);
    final Color primaryGreen = greenDark; // Color(0xFF2E7D32)

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 110, // Aumentado para evitar overflow
      decoration: BoxDecoration(
        // Gradiente sofisticado con múltiples tonos
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFAFDFA), // Blanco verdoso muy claro
            softGreen,
            const Color(0xFFE0F2E1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        // Sombras múltiples para profundidad 3D real
        boxShadow: [
          // Sombra principal
          BoxShadow(
            color: primaryGreen.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          // Sombra de destaque sutil arriba
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
            spreadRadius: -2,
          ),
          // Sombra ambiente suave
          BoxShadow(
            color: primaryGreen.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Container(
        // Borde con gradiente interno premium
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.transparent,
            width: 0,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.8),
              primaryGreen.withOpacity(0.2),
              Colors.white.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(1.5), // Espacio para el borde gradiente
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.5),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFAFDFA),
                softGreen,
                const Color(0xFFE0F2E1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.5),
            child: Row(
              children: [
                // COLUMNA IZQUIERDA - Mis Respuestas
                Expanded(
                  child: _buildPremiumAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Mis Respuestas',
                    primaryGreen: primaryGreen,
                    isLeft: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyRepliesPage(),
                        ),
                      );
                    },
                  ),
                ),

                // DIVIDER VERTICAL ULTRA PREMIUM
                Container(
                  width: 1,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        primaryGreen.withOpacity(0.12),
                        primaryGreen.withOpacity(0.25),
                        primaryGreen.withOpacity(0.12),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // COLUMNA DERECHA - Mis Favoritos
                Expanded(
                  child: _buildPremiumAction(
                    icon: Icons.favorite_border_rounded,
                    label: 'Mis Favoritos',
                    primaryGreen: primaryGreen,
                    isLeft: false,
                    onTap: () {
                      Navigator.pushNamed(context, '/favorites');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar premium con animación
  Widget _buildPremiumAction({
    required IconData icon,
    required String label,
    required Color primaryGreen,
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: primaryGreen.withOpacity(0.1),
        highlightColor: primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.only(
          topLeft: isLeft ? const Radius.circular(22.5) : Radius.zero,
          bottomLeft: isLeft ? const Radius.circular(22.5) : Radius.zero,
          topRight: !isLeft ? const Radius.circular(22.5) : Radius.zero,
          bottomRight: !isLeft ? const Radius.circular(22.5) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Contenedor del ícono con gradiente premium
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  // Gradiente sutil en el fondo del círculo
                  gradient: LinearGradient(
                    colors: [
                      primaryGreen.withOpacity(0.08),
                      primaryGreen.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  // Sombra interna simulada con borde
                  border: Border.all(
                    color: primaryGreen.withOpacity(0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              // Texto con mejor tipografía
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                  height: 1.1,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ HEADER EXPANDIDO CON AVATAR PREMIUM
  Widget _buildExpandedHeader() {
    // Determinar la URL de la foto/avatar
    String? photoUrl;
    if (_userData?['profilePhotoUrl'] != null &&
        _userData!['profilePhotoUrl'].toString().isNotEmpty &&
        _userData!['profilePhotoUrl'].toString() != 'null') {
      photoUrl = _userData!['profilePhotoUrl'];
    } else if (_userData?['avatarId'] != null &&
        _userData!['avatarId'].toString().isNotEmpty &&
        _userData!['avatarId'].toString() != 'null') {
      photoUrl = '/avatars/${_userData!['avatarId']}.png';
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        // Avatar con anillo gradiente premium
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [greenPrimary, greenSecondary, greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: greenPrimary.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: greenSecondary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: photoUrl != null
                  ? NetworkImage(ApiService.getFullImageUrl(photoUrl))
                  : null,
              child: photoUrl == null
                  ? Icon(Icons.person, size: 50, color: greenDark)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Nombre con mejor tipografía
        Text(
          _userData?['fullName'] ?? 'Usuario',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Email con estilo mejorado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _userData?['email'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // HEADER COLAPSADO
  Widget _buildCollapsedHeader() {
    // Determinar la URL de la foto/avatar
    // PRIORIDAD: profilePhotoUrl primero (foto subida), luego avatarId (avatar predefinido)
    String? photoUrl;
    if (_userData?['profilePhotoUrl'] != null &&
        _userData!['profilePhotoUrl'].toString().isNotEmpty &&
        _userData!['profilePhotoUrl'].toString() != 'null') {
      photoUrl = _userData!['profilePhotoUrl'];
    } else if (_userData?['avatarId'] != null &&
        _userData!['avatarId'].toString().isNotEmpty &&
        _userData!['avatarId'].toString() != 'null') {
      photoUrl = '/avatars/${_userData!['avatarId']}.png';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white30,
          backgroundImage: photoUrl != null
              ? NetworkImage(ApiService.getFullImageUrl(photoUrl))
              : null,
          child: photoUrl == null
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

  // ✨ ANIMACIÓN PARA POSTS
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: greenPrimary.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: PostCard(
          post: post,
          currentUserId: _userData?['id'],
          onDeleted: _loadMyPosts,
          onUpdated: _loadMyPosts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight, // Premium light background
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
                              colors: [greenPrimary, greenSecondary, greenDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                          child: SafeArea(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: collapsed
                                    ? _buildCollapsedHeader()
                                    : _buildExpandedHeader(),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [greenSecondary, greenDark],
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
                          const SizedBox(height: 20),
                          // ✨ Botón Editar Perfil Premium
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [greenPrimary, greenSecondary],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: greenPrimary.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/edit-profile',
                                  arguments: _userData,
                                );

                                // Reload user data after returning from edit profile
                                if (result == true) {
                                  print('Recargando perfil despues de edicion...');
                                  await _loadUserData();
                                  print('Perfil recargado');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Editar Perfil',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildProfileActionsCard(),
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
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_myPosts.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No tienes publicaciones',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
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
