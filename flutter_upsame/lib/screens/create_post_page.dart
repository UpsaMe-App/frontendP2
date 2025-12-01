import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CreatePostPage extends StatefulWidget {
  final PostType initialPostType;

  const CreatePostPage({super.key, required this.initialPostType});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _capacityController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  final _calendlyUrlController = TextEditingController();
  final _subjectSearchController = TextEditingController();

  late PostType selectedPostType;
  Subject? _selectedSubject;
  List<Subject> _allSubjects = [];
  List<Subject> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;

  Timer? _debounce;
  File? _selectedImage;
  Uint8List? _imageBytes;
  String? _imageFileName;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;

  // 🎨 UPSA vibes – paleta verde
  final Color primaryDark = const Color(0xFF2E7D32);
  final Color primary = const Color(0xFF388E3C);
  final Color primaryLight = const Color(0xFFC8E6C9);
  final Color bgSoft = const Color(0xFFF1F8E9);

  @override
  void initState() {
    super.initState();
    selectedPostType = widget.initialPostType;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadAllSubjects();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
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
        _searchResults = subjects;
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

    // Validar subject para helper y student
    if (selectedPostType != PostType.comment && _selectedSubject == null) {
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
      switch (selectedPostType) {
        case PostType.helper:
          await ApiService.createHelperPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            subjectId: _selectedSubject!.id,
            capacity: int.parse(_capacityController.text),
            maxCapacity: int.parse(_maxCapacityController.text),
            calendlyUrl: _calendlyUrlController.text.trim(),
          );
          break;
        case PostType.student:
          await ApiService.createStudentPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            subjectId: _selectedSubject!.id,
            image: kIsWeb ? null : _selectedImage,
            imageBytes: _imageBytes,
            imageFileName: _imageFileName,
          );
          break;
        case PostType.comment:
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
        setState(() {
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
          _imageBytes = bytes;
          _imageFileName = image.name;
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

  void _onPostTypeChanged(PostType newType) {
    if (newType != selectedPostType) {
      setState(() {
        selectedPostType = newType;
        _selectedSubject = null;
        _subjectSearchController.clear();
        _searchResults = _allSubjects;
      });
      _animationController.forward(from: 0.0);
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Padding reducido
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
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
                    // Selector de tipo de publicación
                    PostTypeSelector(
                      selectedType: selectedPostType,
                      onTypeChanged: _onPostTypeChanged,
                    ),
                    const SizedBox(height: 24),

                    // Formulario dinámico con animaciones
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: _buildDynamicForm(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón de publicar
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicForm() {
    return Container(
      key: ValueKey(selectedPostType),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtítulo para comentarios
          if (selectedPostType == PostType.comment)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "Comparte tu comentario con la comunidad ✨",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: primaryDark,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Título
          TextFormField(
            controller: _titleController,
            decoration: _inputDecoration(
              selectedPostType == PostType.comment
                  ? 'Título (opcional)'
                  : 'Título',
            ),
            style: GoogleFonts.poppins(fontSize: 14),
            validator: (value) {
              if (selectedPostType != PostType.comment &&
                  (value == null || value.isEmpty)) {
                return 'Por favor ingresa un título';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Contenido
          TextFormField(
            controller: _contentController,
            maxLines: selectedPostType == PostType.comment ? 6 : 5,
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

          // Campos específicos según el tipo
          ...(_buildSpecificFields()),
        ],
      ),
    );
  }

  List<Widget> _buildSpecificFields() {
    switch (selectedPostType) {
      case PostType.helper:
        return _buildHelperFields();
      case PostType.student:
        return _buildStudentFields();
      case PostType.comment:
        return [];
    }
  }

  List<Widget> _buildHelperFields() {
    return [
      // Materia
      _buildSubjectSelector(),
      const SizedBox(height: 16),

      // Capacidades
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

      // URL de Calendly
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
    ];
  }

  List<Widget> _buildStudentFields() {
    return [
      // Materia
      _buildSubjectSelector(),
      const SizedBox(height: 16),

      // Selector de imagen
      _buildImagePicker(),
    ];
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _subjectSearchController,
          decoration:
              _inputDecoration(
                'Materia *',
                hint: 'Toca para ver todas las materias...',
              ).copyWith(
                prefixIcon: Icon(Icons.book, color: primaryDark),
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
        if (_searchResults.isNotEmpty &&
            _subjectSearchController.text != _selectedSubject?.name) ...[
          const SizedBox(height: 8),
          _buildSubjectDropdown(),
        ],
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    return Container(
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
                colors: [primaryLight, primary.withOpacity(0.9)],
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
                const Icon(Icons.list, color: Colors.white, size: 20),
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
                final isSelected = _selectedSubject?.id == subject.id;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.book_outlined,
                    color: isSelected ? primaryDark : primary,
                  ),
                  title: Text(
                    subject.name,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? primaryDark : Colors.black87,
                    ),
                  ),
                  tileColor: isSelected ? primaryLight.withOpacity(0.35) : null,
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
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : Image.file(_selectedImage!, fit: BoxFit.cover),
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
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              label: Text(
                'Eliminar imagen',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryDark.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          borderRadius: BorderRadius.circular(24), // Más redondeado
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _createPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'PUBLICAR',
                  style: GoogleFonts.poppins(
                    fontSize: 17, // Texto más grande
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
        ),
      ),
    );
  }
}

// Widget reutilizable para el selector de tipo de publicación
class PostTypeSelector extends StatelessWidget {
  final PostType selectedType;
  final ValueChanged<PostType> onTypeChanged;

  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de publicación',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PostTypeChip(
                postType: PostType.helper,
                label: 'Ayudante',
                icon: Icons.school,
                color: const Color(0xFFE85D75),
                isSelected: selectedType == PostType.helper,
                onTap: () => onTypeChanged(PostType.helper),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PostTypeChip(
                postType: PostType.student,
                label: 'Estudiante',
                icon: Icons.person,
                color: const Color(0xFF388E3C),
                isSelected: selectedType == PostType.student,
                onTap: () => onTypeChanged(PostType.student),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PostTypeChip(
                postType: PostType.comment,
                label: 'Comentario',
                icon: Icons.comment,
                color: const Color(0xFF9B7EBD),
                isSelected: selectedType == PostType.comment,
                onTap: () => onTypeChanged(PostType.comment),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PostTypeChip extends StatelessWidget {
  final PostType postType;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PostTypeChip({
    required this.postType,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8), // Padding reducido
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20), // Más redondeado
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20, // Icono más pequeño
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12, // Texto más pequeño
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
