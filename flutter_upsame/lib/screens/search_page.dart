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
    setState(() {
      _selectedSubject = subject;
      _isLoadingPosts = true;
      _posts = [];
    });

    try {
      // 🔥 IMPORTANTÍSIMO: el backend espera q = nombre de la materia
      final results = await ApiService.searchPostsBySubject(subject.name);

      setState(() {
        _posts = results;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() => _isLoadingPosts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenLight.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: greenDark,
        elevation: 2,
        title: Text(
          "Buscar Materias",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
          )
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        boxShadow: [
          BoxShadow(
            color: greenDark.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: TextField(
            controller: _searchController,
            onChanged: _searchSubjects,
            decoration: InputDecoration(
              hintText: 'Buscar materia...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: greenDark),
              filled: true,
              fillColor: Colors.white.withOpacity(0.75),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: greenDark),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _subjects = [];
                          _selectedSubject = null;
                          _posts = [];
                        });
                      },
                    )
                  : null,
            ),
            style: GoogleFonts.poppins(),
          ),
        ),
      ),
    );
  }

  // SUBJECT LIST
  Widget _buildSubjectsList() {
    if (_isLoadingSubjects) {
      return const LinearProgressIndicator();
    }

    if (_subjects.isEmpty) {
      if (_searchController.text.isEmpty) return Container();
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No se encontraron materias',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 210),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: greenLight.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: green.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          return ListTile(
            leading: Icon(Icons.book, color: greenDark),
            title: Text(
              subject.name,
              style: GoogleFonts.poppins(fontSize: 15),
            ),
            onTap: () {
              _searchController.text = subject.name;
              setState(() => _subjects = []);
              _loadPostsBySubject(subject);
            },
          );
        },
      ),
    );
  }

  // POSTS LIST
  Widget _buildPostsList() {
    if (_selectedSubject == null) {
      return Center(
        child: Text(
          "Busca una materia",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    if (_isLoadingPosts) {
      return Center(child: CircularProgressIndicator(color: greenDark));
    }

    if (_posts.isEmpty) {
      return Center(
        child: Text(
          "No hay publicaciones",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: _posts[index],
          currentUserId: widget.userId,
          onDeleted: () => _loadPostsBySubject(_selectedSubject!),
          onUpdated: () => _loadPostsBySubject(_selectedSubject!),
        );
      },
    );
  }
}