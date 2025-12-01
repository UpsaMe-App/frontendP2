import 'package:flutter/material.dart';
import 'package:flutter_upsame/screens/post_detail_page.dart';
import 'package:flutter_upsame/screens/user_replies_page.dart';
import 'package:flutter_upsame/screens/user_favorites_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/favorite_button.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  User? _user;
  bool _isLoading = false;
  bool _showCollapsedTitle = false;

  // Paleta de colores - Premium Edition
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _mediumGreen = const Color(0xFF43A047);
  final Color _lightGreen = const Color(0xFF66BB6A);
  final Color _softGreen = const Color(0xFFE8F5E9);
  final Color _borderGreen = const Color(0xFFC8E6C9);
  final Color _accentGreen = const Color(0xFF00C853);

  // Grises cálidos
  final Color _warmGray600 = const Color(0xFF757575);
  final Color _warmGray800 = const Color(0xFF424242);

  // Paleta Calendly (Lila Pastel) - Enhanced
  final Color _calendlyBg = const Color(0xFFF8F0FF);
  final Color _calendlyBgGradient = const Color(0xFFF5EDFF);
  final Color _calendlyBgEnd = const Color(0xFFEDE7F6);
  final Color _calendlyPurple = const Color(0xFF7B1FA2);
  final Color _calendlyIconBg = const Color(0xFFD1C4E9);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadUser();
  }

  void _onScroll() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 180;
    if (shouldShow != _showCollapsedTitle) {
      setState(() {
        _showCollapsedTitle = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await ApiService.getPublicUser(widget.userId);
      print('========================================');
      print('PUBLIC PROFILE - USER DATA');
      print('========================================');
      print('User ID: ${user.id}');
      print('Display Name: ${user.displayName}');
      print('Avatar ID: ${user.avatarId}');
      print('Avatar URL: ${user.avatarUrl}');
      print('Profile Photo URL: ${user.profilePhotoUrl}');
      print('Computed photoUrl: ${user.photoUrl}');
      print('========================================');
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      print('ERROR loading public user: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _launchPhone(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openCalendly() async {
    if (_user?.calendlyUrl == null) return;
    final url = _user!.calendlyUrl!;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Calendly')),
      );
    }
  }

  // --- Helpers de UI ---
  Color _getRoleColor(int role) {
    switch (role) {
      case 1:
        return const Color(0xFFE53935);
      case 2:
        return const Color(0xFF1976D2);
      case 3:
        return const Color(0xFF8E24AA);
      default:
        return Colors.grey;
    }
  }

  String _getRoleText(int role) {
    switch (role) {
      case 1:
        return 'Ofrece Ayuda';
      case 2:
        return 'Busca Ayuda';
      case 3:
        return 'Recomendación';
      default:
        return 'Publicación';
    }
  }

  IconData _getRoleIcon(int role) {
    switch (role) {
      case 1:
        return Icons.volunteer_activism_outlined;
      case 2:
        return Icons.help_outline;
      case 3:
        return Icons.lightbulb_outline;
      default:
        return Icons.article_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Hoy';
    if (difference.inDays == 1) return 'Ayer';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryGreen))
          : _user == null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No se pudo cargar el perfil",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: _loadUser,
              child: Text("Reintentar", style: TextStyle(color: _primaryGreen)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // SliverAppBar verde profesional
          SliverAppBar(
            expandedHeight: 60, // Barra mínima
            pinned: true,
            backgroundColor: _primaryGreen,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FavoriteButton(userId: widget.userId),
              ),
            ],
            title: AnimatedOpacity(
              opacity: _showCollapsedTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: _user!.photoUrl.isNotEmpty
                          ? NetworkImage(ApiService.getFullImageUrl(_user!.photoUrl))
                          : null,
                      backgroundColor: _softGreen,
                      child: _user!.photoUrl.isEmpty
                          ? Icon(Icons.person, size: 16, color: _primaryGreen)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _user!.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_darkGreen, _primaryGreen, _mediumGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          // Contenido sin superposición - limpio y profesional
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 24), // Espacio limpio después del header
                  // Avatar grande centrado
                  _buildBigAvatar(),
                  const SizedBox(height: 16),
                  _buildUserInfo(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildUnifiedInfoCard(),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        if (_user!.calendlyUrl != null &&
                            _user!.calendlyUrl!.isNotEmpty &&
                            _user!.calendlyUrl!.length > 5)
                          _buildCalendlyCard(),
                        const SizedBox(height: 24),
                        _buildPostsList(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigAvatar() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [_accentGreen, _primaryGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: _primaryGreen.withOpacity(0.4),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(5),
          child: ClipOval(
            child: _user!.photoUrl.isNotEmpty
                ? Image.network(
                    ApiService.getFullImageUrl(_user!.photoUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: _softGreen,
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: _primaryGreen,
                      ),
                    ),
                  )
                : Container(
                    color: _softGreen,
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: _primaryGreen,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          _user!.displayName,
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _user!.email,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: _warmGray600,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUnifiedInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _softGreen,
            _softGreen.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _primaryGreen.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCompactInfoItem(
                  icon: Icons.school_rounded,
                  label: "Semestre",
                  value: "${_user!.semester}º",
                  color: Colors.blue,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: _primaryGreen.withOpacity(0.15),
              ),
              Expanded(
                child: _buildCompactInfoItem(
                  icon: Icons.work_rounded,
                  label: "Carrera",
                  value: _user!.career ?? "N/A",
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          if (_user!.phone != null && _user!.phone!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: _primaryGreen.withOpacity(0.15)),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _launchPhone(_user!.phone!),
                borderRadius: BorderRadius.circular(16),
                splashColor: _primaryGreen.withOpacity(0.2),
                highlightColor: _primaryGreen.withOpacity(0.1),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _primaryGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _primaryGreen.withOpacity(0.15),
                              _accentGreen.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_rounded,
                          size: 22,
                          color: _primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _user!.phone!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: _primaryGreen.withOpacity(0.2),
          highlightColor: _primaryGreen.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  _softGreen.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _primaryGreen.withOpacity(0.25),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: _primaryGreen),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: "Respuestas",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserRepliesPage(
                    userId: widget.userId,
                    userName: _user!.displayName.split(' ').first,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.favorite_border_rounded,
            label: "Favoritos",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserFavoritesPage(
                    userId: widget.userId,
                    userName: _user!.displayName.split(' ').first,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendlyCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _calendlyBg,
            _calendlyBgGradient,
            _calendlyBgEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _calendlyPurple.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _calendlyPurple.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: _openCalendly,
          borderRadius: BorderRadius.circular(24),
          splashColor: _calendlyPurple.withOpacity(0.1),
          highlightColor: _calendlyPurple.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _calendlyIconBg,
                        _calendlyIconBg.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _calendlyPurple.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: _calendlyPurple,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Agenda una cita",
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _calendlyPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Conecta vía Calendly",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _warmGray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _calendlyPurple.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _calendlyPurple.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Agendar",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _calendlyPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_user!.posts == null || _user!.posts!.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            "Publicaciones recientes",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _user!.posts!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final post = _user!.posts![index];
            return _buildPostCard(post);
          },
        ),
      ],
    );
  }

  Widget _buildPostCard(Post post) {
    final roleColor = _getRoleColor(post.role);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            roleColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: roleColor.withOpacity(0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: roleColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
            );
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: roleColor.withOpacity(0.1),
          highlightColor: roleColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            roleColor.withOpacity(0.12),
                            roleColor.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: roleColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRoleIcon(post.role),
                            size: 16,
                            color: roleColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getRoleText(post.role),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: roleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(post.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _warmGray600.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  post.title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _warmGray600,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (post.subjectName != null && post.subjectName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _primaryGreen.withOpacity(0.08),
                          _accentGreen.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _primaryGreen.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.book_outlined, size: 14, color: _primaryGreen),
                        const SizedBox(width: 6),
                        Text(
                          post.subjectName!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
