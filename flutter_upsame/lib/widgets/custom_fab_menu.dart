import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../screens/create_post_page.dart';

class CustomFabMenu extends StatefulWidget {
  final VoidCallback? onPostCreated;

  const CustomFabMenu({super.key, this.onPostCreated});

  @override
  State<CustomFabMenu> createState() => _CustomFabMenuState();
}

class _CustomFabMenuState extends State<CustomFabMenu>
    with TickerProviderStateMixin {
  bool isMenuOpen = false;
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  // Colores definidos
  final Color colorAyudante = const Color(0xFF2E7D32); // Verde oscuro
  final Color colorEstudiante = const Color(0xFF388E3C); // Verde medio
  final Color colorComentario = const Color(0xFF388E3C); // Verde medio (Igual a Estudiante)

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 grados
    ).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });

    if (isMenuOpen) {
      _animationController.forward();
      _rotationController.forward();
    } else {
      _animationController.reverse();
      _rotationController.reverse();
    }
  }

  void _navigateToCreatePost(PostType postType) async {
    if (isMenuOpen) {
      _toggleMenu();
    }

    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostPage(initialPostType: postType),
      ),
    );

    if (result == true && widget.onPostCreated != null) {
      widget.onPostCreated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Opciones del menú (solo visibles si está abierto o animando)
        if (isMenuOpen || _animationController.isAnimating)
          Flexible(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 3. Comentario (Top)
                    _buildAnimatedOption(
                      label: 'Comentario',
                      icon: Icons.chat_bubble_outline,
                      color: colorComentario,
                      textColor: Colors.white, 
                      index: 2,
                      onTap: () => _navigateToCreatePost(PostType.comment),
                    ),
                    const SizedBox(height: 16), // Más separación

                    // 2. Estudiante (Middle)
                    _buildAnimatedOption(
                      label: 'Estudiante',
                      icon: Icons.person_outline,
                      color: colorEstudiante,
                      textColor: Colors.white,
                      index: 1,
                      onTap: () => _navigateToCreatePost(PostType.student),
                    ),
                    const SizedBox(height: 16), // Más separación

                    // 1. Ayudante (Bottom)
                    _buildAnimatedOption(
                      label: 'Ayudante',
                      icon: Icons.school_outlined,
                      color: colorAyudante,
                      textColor: Colors.white,
                      index: 0,
                      onTap: () => _navigateToCreatePost(PostType.helper),
                    ),
                    const SizedBox(height: 24), // Separación extra del FAB
                  ],
                );
              },
            ),
          ),

        // FAB Principal
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  heroTag: "main-fab",
                  onPressed: _toggleMenu,
                  backgroundColor: colorAyudante,
                  elevation: 8,
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedOption({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required int index,
    required VoidCallback onTap,
  }) {
    // Ajustamos el offset para que salgan del FAB hacia arriba con más separación
    double value = _slideAnimation.value;
    // Mayor desplazamiento vertical para separar más del FAB
    double yOffset = (1 - value) * 30 * (index + 1); 
    double opacity = _fadeAnimation.value;

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Opacity(
        opacity: opacity,
        child: _buildPillButton(
          label: label,
          icon: icon,
          color: color,
          textColor: textColor,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texto
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 12),
              // Icono en círculo
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: textColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
