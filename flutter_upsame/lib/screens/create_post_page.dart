import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  Uint8List? _imageBytes; // For web support
  String? _imageFileName; // Store original filename with extension
  final ImagePicker _picker = ImagePicker();

  // 🎨 UPSA vibes – paleta verde
  final Color primaryDark = const Color(0xFF2E7D32);
  final Color primary = const Color(0xFF388E3C);
  final Color primaryLight = const Color(0xFFC8E6C9);
  final Color bgSoft = const Color(0xFFF1F8E9);

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
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = _allSubjects;
      });
      return;
    }

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
            image: kIsWeb ? null : _selectedImage,
            imageBytes: _imageBytes,
            imageFileName: _imageFileName,
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

      Navigator.pop(context, true);
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        print('========================================');
        print('IMAGEN SELECCIONADA');
        print('========================================');
        print('Path: ${image.path}');
        print('Name: ${image.name}');
        print('Bytes length: ${bytes.length}');
        print('kIsWeb: $kIsWeb');
        print('========================================');
        setState(() {
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
          _imageBytes = bytes;
          _imageFileName = image.name; // Store filename with extension
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: primaryDark.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: primaryLight.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryLight.withOpacity(0.9),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryLight.withOpacity(0.9),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        title: Text(
          'Nueva Publicación',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primary.withOpacity(0.4),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Card grande contenedora del formulario
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: primaryLight.withOpacity(0.8),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role selector
                    Text(
                      'Tipo de publicación',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
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
                            color: const Color(0xFFE85D75), // rojo rol
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRoleChip(
                            role: 2,
                            label: 'Estudiante',
                            icon: Icons.person,
                            color: primary, // verde UPSA
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
                    const SizedBox(height: 20),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('Título'),
                      style: GoogleFonts.poppins(fontSize: 14),
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
                      decoration: _inputDecoration('Contenido'),
                      style: GoogleFonts.poppins(fontSize: 14),
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
                          decoration:
                              _inputDecoration(
                                'Materia *',
                                hint: 'Toca para ver todas las materias...',
                              ).copyWith(
                                prefixIcon: Icon(
                                  Icons.book,
                                  color: primaryDark,
                                ),
                                suffixIcon: _isSearching
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : _selectedSubject != null
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
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
                      if (_searchResults.isNotEmpty &&
                          _subjectSearchController.text !=
                              _selectedSubject?.name) ...[
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primary, width: 1.6),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryLight,
                                      primary.withOpacity(0.9),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.list,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_searchResults.length} materias disponibles',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
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
                                    final isSelected =
                                        _selectedSubject?.id == subject.id;
                                    return ListTile(
                                      leading: Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.book_outlined,
                                        color: isSelected
                                            ? primaryDark
                                            : primary,
                                      ),
                                      title: Text(
                                        subject.name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? primaryDark
                                              : Colors.black87,
                                        ),
                                      ),
                                      tileColor: isSelected
                                          ? primaryLight.withOpacity(0.35)
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedSubject = subject;
                                          _subjectSearchController.text =
                                              subject.name;
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

                    // Image picker for Student role
                    if (_selectedRole == 2) ...[
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: primaryLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: primaryLight.withOpacity(0.9),
                              width: 1.2,
                            ),
                          ),
                          child: _imageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: kIsWeb
                                      ? Image.memory(
                                          _imageBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: primaryDark.withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Agregar imagen (opcional)',
                                      style: GoogleFonts.poppins(
                                        color: primaryDark.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (_imageBytes != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                                _imageBytes = null;
                                _imageFileName = null;
                              });
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18,
                            ),
                            label: Text(
                              'Eliminar imagen',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ),
                        ),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _inputDecoration('Capacidad actual'),
                              style: GoogleFonts.poppins(fontSize: 14),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _inputDecoration('Capacidad máxima'),
                              style: GoogleFonts.poppins(fontSize: 14),
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
                        decoration: _inputDecoration(
                          'URL de Calendly',
                          hint: 'https://calendly.com/...',
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
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
                  ],
                ),
              ),

              const SizedBox(height: 24), // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: primaryDark.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
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
                              letterSpacing: 0.5,
                            ),
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
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
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
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? color : color.withOpacity(0.7),
          width: 1.8,
        ),
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
