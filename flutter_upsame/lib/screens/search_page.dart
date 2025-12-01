import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';

class SearchPage extends StatefulWidget {
  final String userId;

  const SearchPage({super.key, required this.userId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Subject> _subjects = [];
  List<Post> _posts = [];

  bool _isLoadingSubjects = false;
  bool _isLoadingPosts = false;

  Subject? _selectedSubject;

  final Color greenDark = const Color(0xFF2E7D32);
  final Color green = const Color(0xFF388E3C);
  final Color greenLight = const Color.fromARGB(255, 88, 192, 91);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchSubjects(String query) async {
    if (query.isEmpty) {
      setState(() {
        _subjects = [];
        _selectedSubject = null;
        _posts = [];
      });
      return;
    }

    setState(() => _isLoadingSubjects = true);

    try {
      final results = await ApiService.searchSubjects(query);

      setState(() {
        _subjects = results;
        _isLoadingSubjects = false;

        // Si no hay materias que coincidan, limpiamos también los posts
        if (results.isEmpty) {
          _selectedSubject = null;
          _posts = [];
        }
      });
    } catch (e) {
      setState(() => _isLoadingSubjects = false);
    }
  }

  Future<void> _loadPostsBySubject(Subject subject) async {
    print('🚨🚨🚨 INICIANDO _loadPostsBySubject 🚨🚨🚨');
    print('📚 Subject: ${subject.name}');
    print('📚 Subject ID: ${subject.id}');
    print('⏰ Timestamp: ${DateTime.now()}');
    print('🎯 Current _posts length: ${_posts.length}');

    // LIMPIAR POSTS INMEDIATAMENTE
    setState(() {
      _selectedSubject = subject;
      _isLoadingPosts = true;
      _posts = []; // ⚠️ LIMPIADO FORZOSO
    });

    print('🧹 Posts limpiados, lista actual: ${_posts.length}');

    try {
      print('🔥 LLAMANDO ApiService.searchPostsBySubject(${subject.name})');
      print('🔥 ESTA FUNCIÓN DEBERÍA LANZAR ERROR SI ESTÁ MODIFICADA');

      final results = await ApiService.searchPostsBySubject(subject.name);

      print('✅ RESPUESTA RECIBIDA SIN ERROR - ESTO ES SOSPECHOSO');
      print('📊 Posts recibidos para ${subject.name}: ${results.length}');

      if (results.isEmpty) {
        print('📭 No se recibieron posts');
      } else {
        print('📋 Primeros 5 posts recibidos:');
        for (int i = 0; i < results.length && i < 5; i++) {
          print(
            '  $i. "${results[i].title}" (ID: ${results[i].id}, UserID: ${results[i].userId})',
          );
        }
      }

      setState(() {
        _posts = results;
        _isLoadingPosts = false;
      });

      print('🎯 Posts asignados al widget: ${_posts.length}');
    } catch (e) {
      print('🚨 ERROR CAPTURADO EN _loadPostsBySubject: $e');
      print('🚨 TIPO DE ERROR: ${e.runtimeType}');
      print('🚨 ERROR STRING: ${e.toString()}');

      setState(() {
        _posts = []; // Asegurar que no hay posts en caso de error
        _isLoadingPosts = false;
      });
    }

    print('🏁 FIN DE _loadPostsBySubject - Posts finales: ${_posts.length}');
    print('🚨🚨🚨 FIN _loadPostsBySubject 🚨🚨🚨\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenLight.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: greenDark,
        elevation: 0, // Flat for modern look
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        title: Text(
          "Buscar Materias",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // White text
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              _buildSubjectsList(),
              Expanded(child: _buildPostsList()),
            ],
          ),
          // Gradient fade at top of content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      greenLight.withOpacity(0.12),
                      greenLight.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: greenDark.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: TextField(
                controller: _searchController,
                onChanged: _searchSubjects,
                decoration: InputDecoration(
                  hintText: 'Buscar materia...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search_rounded, color: green),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: green.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectedSubject != null)
                              IconButton(
                                icon: Icon(Icons.refresh_rounded, color: green),
                                onPressed: () async {
                                  print(
                                    '🔄 FORZANDO ACTUALIZACIÓN COMPLETA...',
                                  );
                                  // Limpiar cualquier caché local
                                  setState(() {
                                    _posts.clear();
                                  });
                                  await _loadPostsBySubject(_selectedSubject!);
                                },
                                tooltip: 'Forzar actualización completa',
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _subjects = [];
                                  _selectedSubject = null;
                                  _posts = [];
                                });
                              },
                            ),
                          ],
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SUBJECT LIST
  Widget _buildSubjectsList() {
    if (_isLoadingSubjects) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: green, strokeWidth: 2),
        ),
      );
    }

    if (_subjects.isEmpty) {
      if (_searchController.text.isEmpty) return Container();
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No se encontraron materias',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _subjects.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Colors.grey[100]),
          itemBuilder: (context, index) {
            final subject = _subjects[index];
            return Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: greenLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.book_rounded, color: green, size: 20),
                ),
                title: Text(
                  subject.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
                onTap: () {
                  _searchController.text = subject.name;
                  setState(() => _subjects = []);
                  _loadPostsBySubject(subject);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // POSTS LIST
  Widget _buildPostsList() {
    if (_selectedSubject == null) {
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.08,
              child: Icon(Icons.search_rounded, size: 200, color: greenDark),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 120), // Push text below icon center
                Text(
                  "Busca una materia",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: greenDark.withOpacity(0.6),
                  ),
                ),
                Text(
                  "para ver publicaciones",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: greenDark.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_isLoadingPosts) {
      return Center(child: CircularProgressIndicator(color: green));
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No hay publicaciones aún",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Filtrar posts ocultos localmente
    final visiblePosts = _posts;

    return Column(
      children: [
        // Lista de posts
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: visiblePosts.length,
            itemBuilder: (context, index) {
              final post = visiblePosts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Stack(
                  children: [
                    PostCard(
                      post: post,
                      currentUserId: widget.userId,
                      onDeleted: () {
                        print('🗑️ Post eliminado, refrescando búsqueda...');
                        _loadPostsBySubject(_selectedSubject!);
                      },
                      onUpdated: () {
                        print('✏️ Post actualizado, refrescando búsqueda...');
                        _loadPostsBySubject(_selectedSubject!);
                      },
                    ),

                    // Botón para ocultar post problemático
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const SizedBox.shrink(), // Menú eliminado
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
