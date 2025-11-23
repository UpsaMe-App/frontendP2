import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _capacityController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  final _calendlyUrlController = TextEditingController();
  final _subjectSearchController = TextEditingController();

  int _selectedRole = 1; // 1=ayudante, 2=estudiante, 3=comentario
  Subject? _selectedSubject;
  List<Subject> _allSubjects = [];
  List<Subject> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAllSubjects();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _capacityController.dispose();
    _maxCapacityController.dispose();
    _calendlyUrlController.dispose();
    _subjectSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSubjects() async {
    setState(() {
      _isSearching = true;
    });

    try {
      final subjects = await ApiService.getAllSubjects();
      setState(() {
        _allSubjects = subjects;
        _searchResults = subjects; // Mostrar todas al inicio
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _searchSubjects(String query) async {
    // Cancelar búsqueda anterior
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = _allSubjects;
      });
      return;
    }

    // Debounce de 500ms para no hacer demasiadas peticiones
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isSearching = true;
      });

      try {
        final subjects = await ApiService.searchSubjects(query);
        if (mounted) {
          setState(() {
            _searchResults = subjects;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar subject para roles 1 y 2
    if (_selectedRole != 3 && _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una materia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      switch (_selectedRole) {
        case 1: // Ayudante
          await ApiService.createHelperPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            subjectId: _selectedSubject!.id,
            capacity: int.parse(_capacityController.text),
            maxCapacity: int.parse(_maxCapacityController.text),
            calendlyUrl: _calendlyUrlController.text.trim(),
          );
          break;
        case 2: // Estudiante
          await ApiService.createStudentPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            subjectId: _selectedSubject!.id,
          );
          break;
        case 3: // Comentario
          await ApiService.createCommentPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
          );
          break;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Publicación creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retornar true para indicar que se creó un post
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear publicación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Nueva Publicación',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF66B2A8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role selector
              Text(
                'Tipo de publicación',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildRoleChip(
                      role: 1,
                      label: 'Ayudante',
                      icon: Icons.school,
                      color: const Color(0xFFE85D75),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRoleChip(
                      role: 2,
                      label: 'Estudiante',
                      icon: Icons.person,
                      color: const Color(0xFF66B2A8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRoleChip(
                      role: 3,
                      label: 'Comentario',
                      icon: Icons.comment,
                      color: const Color(0xFF9B7EBD),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Content
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Contenido',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el contenido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subject selector (only for roles 1 and 2)
              if (_selectedRole != 3) ...[
                GestureDetector(
                  onTap: () {
                    if (_allSubjects.isNotEmpty) {
                      setState(() {
                        _searchResults = _allSubjects;
                      });
                    }
                  },
                  child: TextFormField(
                    controller: _subjectSearchController,
                    decoration: InputDecoration(
                      labelText: 'Materia *',
                      hintText: 'Toca para ver todas las materias...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.book, color: Color(0xFF66B2A8)),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _selectedSubject != null
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.arrow_drop_down),
                    ),
                    onChanged: _searchSubjects,
                    onTap: () {
                      if (_allSubjects.isNotEmpty) {
                        setState(() {
                          _searchResults = _allSubjects;
                        });
                      }
                    },
                  ),
                ),
                if (_searchResults.isNotEmpty && _subjectSearchController.text != _selectedSubject?.name) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF66B2A8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5F3),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.list, color: Color(0xFF66B2A8), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${_searchResults.length} materias disponibles',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF66B2A8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final subject = _searchResults[index];
                              final isSelected = _selectedSubject?.id == subject.id;
                              return ListTile(
                                leading: Icon(
                                  isSelected ? Icons.check_circle : Icons.book_outlined,
                                  color: isSelected ? Colors.green : const Color(0xFF66B2A8),
                                ),
                                title: Text(
                                  subject.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.green : Colors.black87,
                                  ),
                                ),
                                tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
                                onTap: () {
                                  setState(() {
                                    _selectedSubject = subject;
                                    _subjectSearchController.text = subject.name;
                                    _searchResults = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Helper specific fields
              if (_selectedRole == 1) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Capacidad actual',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxCapacityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Capacidad máxima',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _calendlyUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL de Calendly',
                    hintText: 'https://calendly.com/...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu URL de Calendly';
                    }
                    if (!value.startsWith('http')) {
                      return 'Ingresa una URL válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D75),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'PUBLICAR',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget _buildRoleChip({
    required int role,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      selectedColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color, width: 2),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedRole = role;
          _selectedSubject = null;
          _subjectSearchController.clear();
          _searchResults = [];
        });
      },
    );
  }
}
