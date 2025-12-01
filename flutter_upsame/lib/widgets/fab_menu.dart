import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../screens/create_post_page.dart';

class FabMenu extends StatefulWidget {
  const FabMenu({super.key});

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Color _greenDark = const Color(0xFF2E7D32);
  final Color _green = const Color(0xFF388E3C);
  final Color _purple = const Color(0xFF7B1FA2);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _navigateToCreatePost(PostType postType) {
    _toggleMenu();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostPage(initialPostType: postType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Menu items
        if (_isOpen) ...[
          _buildMenuItem(
            label: 'Ayudante',
            icon: Icons.school_rounded,
            color: _green,
            onTap: () => _navigateToCreatePost(PostType.helper),
            delay: 0,
          ),
          _buildMenuItem(
            label: 'Estudiante',
            icon: Icons.person_rounded,
            color: _green,
            onTap: () => _navigateToCreatePost(PostType.student),
            delay: 50,
          ),
          _buildMenuItem(
            label: 'Comentario',
            icon: Icons.chat_bubble_rounded,
            color: _purple,
            onTap: () => _navigateToCreatePost(PostType.comment),
            delay: 100,
          ),
        ],

        // Main FAB
        _buildMainFab(),
      ],
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    final index = delay ~/ 50;
    final bottomPosition = 80.0 + (index * 70.0);

    return Positioned(
      bottom: bottomPosition,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(_scaleAnimation),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Icon button
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFab() {
    return FloatingActionButton(
      onPressed: _toggleMenu,
      backgroundColor: _greenDark,
      elevation: 8,
      child: AnimatedRotation(
        turns: _isOpen ? 0.125 : 0,
        duration: const Duration(milliseconds: 250),
        child: Icon(
          _isOpen ? Icons.close_rounded : Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
