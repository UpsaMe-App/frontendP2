import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();
  final GlobalKey _aboutUsKey = GlobalKey();

  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _fallingLeavesController;

  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fallingAnimation;

  bool _hasAnimatedTutorial = false;
  bool _hasAnimatedAboutUs = false;

  // ✅ Helpers para responsividad REAL (incluye iPhone 14 Pro)
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;
  EdgeInsets get _viewPadding => MediaQuery.of(context).padding;

  bool get _isMobile => _screenWidth < 768;
  bool get _isTablet => _screenWidth >= 768 && _screenWidth < 1024;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fallingLeavesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Dejo un valor grande para que cubra pantallas altas; visualmente funciona bien en todos
    _fallingAnimation = Tween<double>(begin: -100, end: 1200).animate(
      CurvedAnimation(parent: _fallingLeavesController, curve: Curves.linear),
    );

    _fadeController.forward();
  }

  void _onScroll() {
    final tutorialContext = _tutorialKey.currentContext;
    final aboutUsContext = _aboutUsKey.currentContext;

    if (tutorialContext != null && !_hasAnimatedTutorial) {
      final tutorialPosition = tutorialContext.findRenderObject() as RenderBox?;
      if (tutorialPosition != null) {
        final tutorialTop = tutorialPosition.localToGlobal(Offset.zero).dy;
        final screenHeight = _screenHeight;

        if (tutorialTop < screenHeight * 0.8) {
          setState(() {
            _hasAnimatedTutorial = true;
          });
        }
      }
    }

    if (aboutUsContext != null && !_hasAnimatedAboutUs) {
      final aboutUsPosition = aboutUsContext.findRenderObject() as RenderBox?;
      if (aboutUsPosition != null) {
        final aboutUsTop = aboutUsPosition.localToGlobal(Offset.zero).dy;
        final screenHeight = _screenHeight;

        if (aboutUsTop < screenHeight * 0.8) {
          setState(() {
            _hasAnimatedAboutUs = true;
          });
        }
      }
    }
  }

  Widget _buildFloatingCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _floatingController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _fallingLeavesController.dispose();
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

  void _showAboutUsPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AboutUsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Color(0xFF0D5C63),
              Color(0xFF1A8E6B),
              Color(0xFF2BB673),
              Color(0xFF44A080),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildHeroSection(),
              _buildAboutUsPreviewSection(),
              _buildTutorialSection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    // ✅ Hero adaptado: llena pantalla en iPhone 14 Pro y otros móviles altos
    final double heroHeight = _isMobile
        ? max(620, _screenHeight) // en iPhone 14 Pro ≈ 844, queda full-screen
        : max(750, _screenHeight * 0.9);

    return SizedBox(
      width: double.infinity,
      height: heroHeight,
      child: Stack(
        children: [
          // Falling leaves background
          AnimatedBuilder(
            animation: _fallingLeavesController,
            builder: (context, child) {
              return Stack(
                children: List.generate(_isMobile ? 8 : 12, (index) {
                  double speed = 0.3 + (index % 4) * 0.2;
                  double rotation =
                      _fallingLeavesController.value * (1.0 + index % 3);
                  double opacity = 0.05 + (index % 4) * 0.03;
                  double left = (index *
                          (_isMobile
                              ? 50.0
                              : 100.0)) %
                      (_isMobile ? 300 : 400);

                  return Positioned(
                    left: left,
                    top: _fallingAnimation.value * speed,
                    child: Transform.rotate(
                      angle: index.isEven ? rotation : -rotation,
                      child: _buildLeaf(
                        const Color(0xFF2D5A52).withOpacity(opacity),
                        _isMobile
                            ? 25 + (index % 3) * 8
                            : 35 + (index % 3) * 10,
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Animated background elements
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: -60 + _floatingAnimation.value * 0.8,
                    top: 80 + _viewPadding.top * 0.2,
                    child: _buildFloatingCircle(
                      _isMobile ? 120 : 180,
                      Colors.white,
                      _isMobile ? 0.03 : 0.05,
                    ),
                  ),
                  Positioned(
                    right: -90 + _floatingAnimation.value * -1.2,
                    top: 180 + _viewPadding.top * 0.1,
                    child: _buildFloatingCircle(
                      _isMobile ? 150 : 220,
                      Colors.white,
                      _isMobile ? 0.02 : 0.04,
                    ),
                  ),
                  if (!_isMobile) ...[
                    Positioned(
                      left: 120 + _floatingAnimation.value * 0.6,
                      bottom: 70,
                      child: _buildFloatingCircle(140, Colors.white, 0.03),
                    ),
                    Positioned(
                      right: 160 + _floatingAnimation.value * -0.9,
                      bottom: 160,
                      child: _buildFloatingCircle(190, Colors.white, 0.04),
                    ),
                  ],
                ],
              );
            },
          ),

          // Header with navigation
          Positioned(
            // ✅ Respeta notch / dynamic island
            top: _viewPadding.top + (_isMobile ? 12 : 24),
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: _isMobile ? 20 : 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isMobile ? 16 : 24,
                          vertical: _isMobile ? 8 : 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(_isMobile ? 15 : 20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          'UpsaMe',
                          style: GoogleFonts.poppins(
                            fontSize: _isMobile ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [
                                  Color(0xFF0D5C63),
                                  Color(0xFF1A8E6B),
                                ],
                              ).createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  200,
                                  70,
                                ),
                              ),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    _isMobile
                        ? _buildMobileNavigation()
                        : _buildDesktopNavigation(),
                  ],
                ),
              ),
            ),
          ),

          // Main content - Responsive
          Center(
            child: _isMobile ? _buildMobileContent() : _buildDesktopContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigation() {
    return Row(
      children: [
        _buildNavButton('¿QUIÉNES SOMOS?', _showAboutUsPage),
        const SizedBox(width: 20),
        _buildNavButton('¿QUÉ HACEMOS?', _scrollToTutorial),
        const SizedBox(width: 20),
        ScaleTransition(
          scale: _pulseAnimation,
          child: ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              elevation: 8,
              shadowColor: const Color(0xFFFF6B6B).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            child: const Row(
              children: [
                Text('UNITE'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNavigation() {
    return IconButton(
      onPressed: _showMobileMenu,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: _screenHeight * 0.6,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D5C63).withOpacity(0.98),
              const Color(0xFF1A8E6B).withOpacity(0.98),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 30),
              _buildMobileNavItem(
                  '¿QUIÉNES SOMOS?', Icons.people_alt_rounded, _showAboutUsPage),
              const SizedBox(height: 20),
              _buildMobileNavItem(
                  '¿QUÉ HACEMOS?', Icons.help_rounded, _scrollToTutorial),
              const SizedBox(height: 20),
              _buildMobileNavItem(
                  'UNITE', Icons.rocket_launch_rounded, _navigateToLogin),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'UpsaMe - Conectando la comunidad académica',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(
      String text, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onPressed();
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isTablet ? 40 : 80),
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
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'UN ESPACIO DISEÑADO PARA VINCULAR AYUDANTES Y ESTUDIANTES. FACILITAR LA COORDINACIÓN ACADÉMICA Y UNIFICAR TODA LA INFORMACIÓN EN UN SOLO LUGAR',
                    style: GoogleFonts.poppins(
                      fontSize: _isTablet ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      onPressed: _navigateToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: _isTablet ? 30 : 40,
                          vertical: _isTablet ? 16 : 18,
                        ),
                        elevation: 6,
                        shadowColor:
                            const Color(0xFFFF6B6B).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: _isTablet ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('UNITE'),
                          SizedBox(width: _isTablet ? 8 : 10),
                          Icon(Icons.rocket_launch_rounded,
                              size: _isTablet ? 18 : 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: _isTablet ? 40 : 80),

          // Right side - Owl animation
          if (!_isTablet)
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 400,
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
                      child: Lottie.network(
                        'https://lottie.host/6a879b42-118e-489a-972a-935c4262ccb9/UDCc6lYM4m.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1A8E6B),
                                  Color(0xFF2BB673),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
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
                  const SizedBox(height: 20),
                  Text(
                    '¡VOS PODÉS!',
                    style: GoogleFonts.pacifico(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(3, 3),
                          blurRadius: 8,
                        ),
                        Shadow(
                          color: const Color(0xFF0D5C63).withOpacity(0.3),
                          offset: const Offset(-1, -1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        // ✅ Baja un poco respetando notch / status bar
        80 + _viewPadding.top * 0.4,
        20,
        20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'UN ESPACIO DISEÑADO PARA VINCULAR AYUDANTES Y ESTUDIANTES. FACILITAR LA COORDINACIÓN ACADÉMICA Y UNIFICAR TODA LA INFORMACIÓN EN UN SOLO LUGAR',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.4,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Column(
            children: [
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Lottie.network(
                    'https://lottie.host/6a879b42-118e-489a-972a-935c4262ccb9/UDCc6lYM4m.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1A8E6B),
                              Color(0xFF2BB673),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.flutter_dash,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '¡VOS PODÉS!',
                style: GoogleFonts.pacifico(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(3, 3),
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: const Color(0xFF0D5C63).withOpacity(0.3),
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ScaleTransition(
            scale: _pulseAnimation,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  elevation: 6,
                  shadowColor: const Color(0xFFFF6B6B).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('UNITE'),
                    SizedBox(width: 10),
                    Icon(Icons.rocket_launch_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaf(Color color, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: LeafPainter(color: color)),
    );
  }

  Widget _buildAboutUsPreviewSection() {
    return Container(
      key: _aboutUsKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: _isMobile ? 60 : 100,
        horizontal: _isMobile ? 20 : 40,
      ),
      child: Column(
        children: [
          AnimatedOpacity(
            opacity: _hasAnimatedAboutUs ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 800),
              padding: EdgeInsets.only(
                  bottom: _hasAnimatedAboutUs ? 0 : 50),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _isMobile ? 20 : 30,
                  vertical: _isMobile ? 12 : 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(_isMobile ? 20 : 25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'CONÓCENOS MEJOR',
                  style: GoogleFonts.poppins(
                    fontSize: _isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D5C63),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: _isMobile ? 30 : 40),
          AnimatedOpacity(
            opacity: _hasAnimatedAboutUs ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                  0, _hasAnimatedAboutUs ? 0 : 50, 0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showAboutUsPage,
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                          _isMobile ? 25 : 40),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B6B)
                                .withOpacity(0.05),
                            const Color(0xFF4ECDC4)
                                .withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            size: _isMobile ? 50 : 60,
                            color: const Color(0xFF0D5C63)
                                .withOpacity(0.7),
                          ),
                          SizedBox(
                              height: _isMobile ? 15 : 20),
                          Text(
                            'Conoce al equipo detrás de UpsaMe',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize:
                                  _isMobile ? 20 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                              height: _isMobile ? 10 : 15),
                          Text(
                            'Descubre nuestra misión, visión y al talentoso equipo de desarrolladores que hizo posible este proyecto',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize:
                                  _isMobile ? 14 : 16,
                              color: Colors.white
                                  .withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(
                              height: _isMobile ? 20 : 25),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  _isMobile ? 25 : 30,
                              vertical:
                                  _isMobile ? 12 : 15,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D5C63),
                              borderRadius:
                                  BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0D5C63)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'VER MÁS',
                                  style: GoogleFonts.poppins(
                                    fontSize:
                                        _isMobile ? 14 : 16,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        _isMobile ? 6 : 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSection() {
    return Container(
      key: _tutorialKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: _isMobile ? 60 : 100,
        horizontal: _isMobile ? 20 : 40,
      ),
      child: Column(
        children: [
          AnimatedOpacity(
            opacity: _hasAnimatedTutorial ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 800),
              padding: EdgeInsets.only(
                  bottom: _hasAnimatedTutorial ? 0 : 50),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _isMobile ? 20 : 30,
                  vertical: _isMobile ? 12 : 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(_isMobile ? 20 : 25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  '¿CÓMO USAR UPSAME?',
                  style: GoogleFonts.poppins(
                    fontSize: _isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D5C63),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: _isMobile ? 40 : 60),
          _isMobile ? _buildMobileSteps() : _buildDesktopSteps(),
        ],
      ),
    );
  }

  Widget _buildDesktopSteps() {
    return Column(
      children: [
        _buildStepCard(
          step: 1,
          title: 'REGÍSTRATE',
          description:
              'Crea tu cuenta con tu correo universitario y completa tu perfil.',
          isVisible: _hasAnimatedTutorial,
        ),
        const SizedBox(height: 25),
        _buildStepCard(
          step: 2,
          title: 'EXPLORA EL HOME',
          description: 'Accede a todos los posts publicados.',
          isVisible: _hasAnimatedTutorial,
        ),
        const SizedBox(height: 25),
        _buildStepCard(
          step: 3,
          title: 'CREA O SOLICITA AYUDANTÍAS',
          description:
              'Los ayudantes publican horarios y materias con Calendly integrado.\nLos estudiantes envían solicitudes directamente desde el post.',
          isVisible: _hasAnimatedTutorial,
        ),
        const SizedBox(height: 25),
        _buildStepCard(
          step: 4,
          title: 'INTERACTÚA EN LOS POSTS',
          description:
              'Publica comentarios, participa en discusiones y mantente al tanto con las notificaciones automáticas.',
          isVisible: _hasAnimatedTutorial,
        ),
        const SizedBox(height: 25),
        _buildStepCard(
          step: 5,
          title: 'ADMINISTRA TU PERFIL',
          description:
              'Edita tus datos, revisa solo tus propios posts (estilo feed personal) y actualiza tu avatar cuando quieras.',
          isVisible: _hasAnimatedTutorial,
        ),
      ],
    );
  }

  Widget _buildMobileSteps() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMobileStepCard(
          step: 1,
          title: 'REGÍSTRATE',
          description:
              'Crea tu cuenta con tu correo universitario y completa tu perfil.',
          isVisible: _hasAnimatedTutorial,
        ),
        const SizedBox(height: 20),
        _buildMobileStepCard(
          step: 2,
          title: 'EXPLORA EL HOME',
          description: 'Accede a todos los posts publicados.',
          isVisible: _hasAnimatedTutorial,
        ),
        const SizedBox(height: 20),
        _buildMobileStepCard(
          step: 3,
          title: 'CREA O SOLICITA AYUDANTÍAS',
          description:
              'Los ayudantes publican horarios y materias con Calendly integrado. Los estudiantes envían solicitudes directamente desde el post.',
          isVisible: _hasAnimatedTutorial,
        ),
        const SizedBox(height: 20),
        _buildMobileStepCard(
          step: 4,
          title: 'INTERACTÚA EN LOS POSTS',
          description:
              'Publica comentarios, participa en discusiones y mantente al tanto con las notificaciones automáticas.',
          isVisible: _hasAnimatedTutorial,
        ),
        const SizedBox(height: 20),
        _buildMobileStepCard(
          step: 5,
          title: 'ADMINISTRA TU PERFIL',
          description:
              'Edita tus datos, revisa solo tus propios posts (estilo feed personal) y actualiza tu avatar cuando quieras.',
          isVisible: _hasAnimatedTutorial,
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required int step,
    required String title,
    required String description,
    required bool isVisible,
  }) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFFE66D),
      const Color(0xFFC44569),
    ];

    final color = colors[(step - 1) % colors.length];

    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (step * 100)),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(isVisible ? 0 : 100, 0, 0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(15),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.05),
                    Colors.white.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: color.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          step.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
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
        ),
      ),
    );
  }

  Widget _buildMobileStepCard({
    required int step,
    required String title,
    required String description,
    required bool isVisible,
  }) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFFE66D),
      const Color(0xFFC44569),
    ];

    final color = colors[(step - 1) % colors.length];

    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (step * 100)),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, isVisible ? 0 : 30, 0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(15),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.05),
                    Colors.white.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: color.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          step.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
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
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: _isMobile ? 30 : 50,
        horizontal: _isMobile ? 20 : 40,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D5C63),
            Color(0xFF0A4A4F),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _isMobile
              ? _buildMobileFooterContent()
              : _buildDesktopFooterContent(),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
          Text(
            'Conectando la comunidad académica de la UPSA',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: _isMobile ? 12 : 14,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFooterContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Creado por estudiantes de la UPSA ❤️',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '© 2025 UpsaMe — Todos los derechos reservados.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooterContent() {
    return Column(
      children: [
        Text(
          'Creado por estudiantes de la UPSA ❤️',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '© 2025 UpsaMe — Todos los derechos reservados.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D5C63),
              Color(0xFF1A8E6B),
              Color(0xFF2BB673),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 15 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0D5C63).withOpacity(0.9),
                      const Color(0xFF1A8E6B).withOpacity(0.9),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: isMobile ? 20 : 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 15 : 20),
                    Expanded(
                      child: Text(
                        '¿Quiénes Somos?',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 20 : 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMissionVisionSection(isMobile),
                        SizedBox(height: isMobile ? 30 : 40),
                        _buildTeamSection(isMobile, isTablet),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionVisionSection(bool isMobile) {
    return Column(
      children: [
        _buildMissionVisionCard(
          title: 'MISIÓN',
          titleColor: const Color(0xFFFF6B6B),
          content:
              'Conectar estudiantes y ayudantes de la UPSA en un solo espacio digital, simple, rápido y organizado; donde cada usuario pueda encontrar apoyo académico, coordinar horarios, compartir conocimientos y tener toda su información centralizada sin perder tiempo.',
          icon: Icons.flag_rounded,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 20 : 30),
        _buildMissionVisionCard(
          title: 'VISIÓN',
          titleColor: const Color(0xFF4ECDC4),
          content:
              'Convertirnos en la plataforma académica líder para la UPSA, impulsando una cultura de colaboración, eficiencia y aprendizaje inteligente, integrando herramientas modernas que automaticen procesos, fortalezcan la comunidad y mejoren la experiencia universitaria de cada estudiante.',
          icon: Icons.visibility_rounded,
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildMissionVisionCard({
    required String title,
    required Color titleColor,
    required String content,
    required IconData icon,
    required bool isMobile,
  }) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 15 : 20),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              titleColor.withOpacity(0.03),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isMobile ? 15 : 20),
          border: Border.all(
            color: titleColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isMobile ? 40 : 50,
                    height: isMobile ? 40 : 50,
                    decoration: BoxDecoration(
                      color: titleColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: titleColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isMobile ? 20 : 28,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 15),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      shadows: [
                        Shadow(
                          color: titleColor.withOpacity(0.2),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 15 : 20),
              Container(
                height: 2,
                width: isMobile ? 80 : 100,
                color: titleColor.withOpacity(0.3),
              ),
              SizedBox(height: isMobile ? 15 : 20),
              Text(
                content,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  color: const Color(0xFF0D5C63).withOpacity(0.8),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(bool isMobile, bool isTablet) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 30,
              vertical: isMobile ? 12 : 15,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0D5C63),
              borderRadius:
                  BorderRadius.circular(isMobile ? 20 : 25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              'NUESTRO EQUIPO',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 30),
        if (isMobile)
          _buildMobileTeamGrid()
        else if (isTablet)
          _buildTabletTeamGrid()
        else
          _buildDesktopTeamGrid(),
      ],
    );
  }

  Widget _buildDesktopTeamGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.8,
      children: _buildTeamMembers(false),
    );
  }

  Widget _buildTabletTeamGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.1,
      children: _buildTeamMembers(false),
    );
  }

  Widget _buildMobileTeamGrid() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: _buildTeamMembers(true),
        ),
      ],
    );
  }

  List<Widget> _buildTeamMembers(bool isMobile) {
    final members = [
      _buildTeamMemberCard(
        name: 'Maria Flavia Lozada Rueda',
        role: 'Full Stack Developer',
        career: 'Ingeniería de Sistemas, Cuarto semestre',
        isFemale: true,
        color: const Color(0xFFFF6B6B),
        isMobile: isMobile,
      ),
      _buildTeamMemberCard(
        name: 'Maria Fernanda Sanchez Arauz',
        role: 'Full Stack Developer',
        career: 'Ingeniería de Sistemas, Cuarto semestre',
        isFemale: true,
        color: const Color(0xFF4ECDC4),
        isMobile: isMobile,
      ),
      _buildTeamMemberCard(
        name: 'Jose Mario Nuñez Justiniano',
        role: 'Full Stack Developer',
        career: 'Ingeniería de Sistemas, Cuarto semestre',
        isFemale: false,
        color: const Color(0xFF45B7D1),
        isMobile: isMobile,
      ),
      _buildTeamMemberCard(
        name: 'Eiver David Romero Justiniano',
        role: 'Full Stack Developer',
        career: 'Ingeniería de Sistemas, Cuarto semestre',
        isFemale: false,
        color: const Color(0xFF96CEB4),
        isMobile: isMobile,
      ),
    ];

    if (isMobile) {
      final mobileMembers = <Widget>[];
      for (var member in members) {
        mobileMembers.add(member);
        mobileMembers.add(const SizedBox(height: 15));
      }
      if (mobileMembers.isNotEmpty) mobileMembers.removeLast();
      return mobileMembers;
    }

    return members;
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String career,
    required bool isFemale,
    required Color color,
    required bool isMobile,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(isMobile ? 15 : 20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.08),
                  color.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(isMobile ? 15 : 20),
              border: Border.all(
                color: color.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding:
                  EdgeInsets.all(isMobile ? 15 : 20),
              child: isMobile
                  ? _buildMobileTeamMemberContent(
                      name, role, career, isFemale, color)
                  : _buildDesktopTeamMemberContent(
                      name, role, career, isFemale, color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTeamMemberContent(
      String name,
      String role,
      String career,
      bool isFemale,
      Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isFemale ? Icons.person_2_rounded : Icons.person_rounded,
            size: 35,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D5C63),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          role,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          career,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF0D5C63).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTeamMemberContent(
      String name,
      String role,
      String career,
      bool isFemale,
      Color color) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            isFemale ? Icons.person_2_rounded : Icons.person_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D5C63),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                career,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF0D5C63).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LeafPainter extends CustomPainter {
  final Color color;

  const LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

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

    final veinPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final veinPath = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.5, size.height);

    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
