import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'directory_page.dart';
import 'profile_page.dart';
import '../widgets/custom_fab_menu.dart';

class MainLayout extends StatefulWidget {
  final String userId;

  const MainLayout({super.key, required this.userId});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  final Color _greenDark = const Color(0xFF2E7D32);
  final Color _green = const Color(0xFF388E3C);
  final Color _greenMedium = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(userId: widget.userId),
      SearchPage(userId: widget.userId),
      const DirectoryPage(),
      ProfilePage(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildGlassmorphismBottomNav(),
      floatingActionButton:
          _currentIndex ==
              0 // Solo mostrar en home page
          ? Padding(
              padding: const EdgeInsets.only(bottom: 24), // FAB más arriba
              child: CustomFabMenu(
                onPostCreated: () {
                  // Refrescar la HomePage si está activa
                  if (_currentIndex == 0) {
                    // Trigger refresh for HomePage
                  }
                },
              ),
            )
          : null, // No mostrar FAB en otras pantallas
    );
  }

  Widget _buildGlassmorphismBottomNav() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.85),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: _greenDark.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
              _buildNavItem(
                icon: Icons.search_rounded,
                label: 'Buscar',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.folder_rounded,
                label: 'Directorio',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 40,
            height: 40,
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_green, _greenMedium],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _green.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : null,
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: isSelected ? 22 : 20,
            ),
          ),
        ),
      ),
    );
  }
}
