import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';

class SearchPage extends StatefulWidget {
  final String userId;

  const SearchPage({
    super.key,
    required this.userId,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<Subject> _subjects = [];
  List<Post> _posts = [];
  bool _isLoadingSubjects = false;
  bool _isLoadingPosts = false;
  Subject? _selectedSubject;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchSubjects(String query) async {
    if (query.isEmpty) {
      setState(() {
        _subjects = [];
      });
      return;
    }

    setState(() {
      _isLoadingSubjects = true;
    });

    try {
      final subjects = await ApiService.searchSubjects(query);
      setState(() {
        _subjects = subjects;
        _isLoadingSubjects = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSubjects = false;
      });
    }
  }

  Future<void> _loadPostsBySubject(Subject subject) async {
    setState(() {
      _isLoadingPosts = true;
      _selectedSubject = subject;
    });

    try {
      final posts = await ApiService.searchPostsBySubject(subject.id);
      setState(() {
        _posts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Buscar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF66B2A8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar materia...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFE8F5F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _subjects = [];
                                _posts = [];
                                _selectedSubject = null;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: _searchSubjects,
                  onSubmitted: (_) {
                    if (_subjects.isNotEmpty) {
                      _loadPostsBySubject(_subjects.first);
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (_isLoadingSubjects)
                  const LinearProgressIndicator()
                else if (_subjects.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        return ListTile(
                          title: Text(
                            subject.name,
                            style: GoogleFonts.poppins(),
                          ),
                          onTap: () {
                            _searchController.text = subject.name;
                            setState(() {
                              _subjects = [];
                            });
                            _loadPostsBySubject(subject);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoadingPosts
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF66B2A8)))
                : _selectedSubject != null
                    ? Column(
                        children: [
                          // Selected subject header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.book, color: Color(0xFF66B2A8)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Publicaciones de:',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        _selectedSubject!.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF4A8B82),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5F3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_posts.length} post${_posts.length != 1 ? 's' : ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF66B2A8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Posts list
                          Expanded(
                            child: _posts.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inbox_outlined,
                                          size: 80,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No hay publicaciones',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Aún no hay posts para esta materia',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                                    itemCount: _posts.length,
                                    itemBuilder: (context, index) {
                                      return PostCard(
                                        post: _posts[index],
                                        currentUserId: widget.userId,
                                        onDeleted: () => _loadPostsBySubject(_selectedSubject!),
                                        onUpdated: () => _loadPostsBySubject(_selectedSubject!),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Busca una materia',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Escribe el nombre de la materia en el campo de búsqueda para ver todas las publicaciones relacionadas',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
