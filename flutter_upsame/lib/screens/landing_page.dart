import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();

  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  Widget _buildFloatingCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _floatingController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToTutorial() {
    final context = _tutorialKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(),
            // Tutorial Section
            _buildTutorialSection(),
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 700,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF66B2A8),
            const Color(0xFF4A8B82),
            const Color(0xFF357067),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated background circles
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: -50 + _floatingAnimation.value,
                    top: 100,
                    child: _buildFloatingCircle(150, Colors.white.withOpacity(0.05)),
                  ),
                  Positioned(
                    right: -80 + _floatingAnimation.value * -1,
                    top: 200,
                    child: _buildFloatingCircle(200, Colors.white.withOpacity(0.08)),
                  ),
                  Positioned(
                    left: 100 + _floatingAnimation.value * 0.5,
                    bottom: 50,
                    child: _buildFloatingCircle(120, Colors.white.withOpacity(0.06)),
                  ),
                  Positioned(
                    right: 150 + _floatingAnimation.value * -0.7,
                    bottom: 150,
                    child: _buildFloatingCircle(180, Colors.white.withOpacity(0.07)),
                  ),
                ],
              );
            },
          ),
          
          // Animated decorative leaves
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: 30,
                    top: 120 + _floatingAnimation.value,
                    child: Transform.rotate(
                      angle: _floatingController.value * 0.2,
                      child: _buildLeaf(),
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: 280 + _floatingAnimation.value * -1,
                    child: Transform.rotate(
                      angle: _floatingController.value * -0.3,
                      child: _buildLeaf(),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    top: 180 + _floatingAnimation.value * 1.5,
                    child: Transform.rotate(
                      angle: _floatingController.value * 0.25,
                      child: _buildLeaf(),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Animated Header with buttons
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Animated Logo
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                            ),
                            child: Text(
                              'UpsaMe',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Navigation buttons with animation
                    Row(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: TextButton(
                            onPressed: _scrollToTutorial,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              backgroundColor: Colors.white.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            child: const Text('WHAT WE DO'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: ElevatedButton(
                            onPressed: _navigateToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE85D75),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFFE85D75).withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            child: Row(
                              children: const [
                                Text('WORK WITH US'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side - Text content
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UN ESPACIO DISEÑADO PARA VINCULAR AYUDANTES Y ESTUDIANTES. FACILITAR LA COORDINACIÓN ACADÉMICA Y UNIFICAR TODA LA INFORMACIÓN EN UN SOLO LUGAR',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _navigateToLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE85D75),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('WORK WITH US'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 60),
                  // Right side - Owl image
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1580982324927-c05278e6a607?w=400&h=400&fit=crop',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.amber.shade700,
                              child: const Icon(
                                Icons.flutter_dash,
                                size: 150,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
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

  Widget _buildLeaf() {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: LeafPainter(),
      ),
    );
  }

  Widget _buildTutorialSection() {
    return Container(
      key: _tutorialKey,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF66B2A8),
            const Color(0xFF4A8B82),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 60),
      child: Column(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '¿CÓMO USAR UPSAME?',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A8B82),
              ),
            ),
          ),
          const SizedBox(height: 60),

          // Steps
          _buildStep(
            number: '1',
            title: 'REGÍSTRATE',
            description: 'Crea tu cuenta con tu correo universitario y completa tu perfil.',
          ),
          const SizedBox(height: 30),
          _buildStep(
            number: '2',
            title: 'EXPLORA EL HOME',
            description: 'Accede a todos los posts publicados.',
          ),
          const SizedBox(height: 30),
          _buildStep(
            number: '3',
            title: 'CREA O SOLICITA AYUDANTÍAS',
            description:
                'Los ayudantes publican horarios y materias con Calendly integrado.\nLos estudiantes envían solicitudes directamente desde el post.',
          ),
          const SizedBox(height: 30),
          _buildStep(
            number: '4',
            title: 'RECIBE Y GESTIONA NOTIFICACIONES',
            description:
                'Acepta, rechaza o deja pendientes las solicitudes.\nTambién recibes alertas cuando alguien comenta o responde en tus posts.',
          ),
          const SizedBox(height: 30),
          _buildStep(
            number: '5',
            title: 'INTERACTÚA EN LOS POSTS',
            description:
                'Publica comentarios, participa en discusiones y mantente al tanto con las notificaciones automáticas.',
          ),
          const SizedBox(height: 30),
          _buildStep(
            number: '6',
            title: 'ADMINISTRA TU PERFIL',
            description:
                'Edita tus datos, revisa solo tus propios posts (estilo feed personal) y actualiza tu avatar cuando quieras.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF5A9A91).withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A8B82),
            Color(0xFF3A6B62),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Creado por estudiantes de la UPSA ❤️',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            '© 2025 UpsaMe — Todos los derechos reservados.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D5A52).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Leaf shape
    path.moveTo(size.width * 0.5, 0);
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.3,
      size.width * 0.5,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.5,
      0,
    );

    canvas.drawPath(path, paint);

    // Center vein
    final veinPaint = Paint()
      ..color = const Color(0xFF2D5A52).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final veinPath = Path();
    veinPath.moveTo(size.width * 0.5, 0);
    veinPath.lineTo(size.width * 0.5, size.height);

    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}