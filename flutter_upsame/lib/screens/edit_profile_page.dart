import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _semesterController;
  late TextEditingController _calendlyUrlController;

  List<Career> _careers = [];
  List<Avatar> _avatars = [];
  String? _selectedCareerId;
  String? _selectedAvatarId;
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();

    // Split fullName into firstName and lastName if available
    String fullName = widget.userData['fullName'] ?? '';
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _phoneController = TextEditingController(
      text: widget.userData['phone'] ?? '',
    );
    _semesterController = TextEditingController(
      text: widget.userData['semester'].toString(),
    );
    _calendlyUrlController = TextEditingController(
      text: widget.userData['calendlyUrl'] ?? '',
    );
    _selectedCareerId = widget.userData['careerId'];

    // Extract avatar ID from profilePhotoUrl if it exists
    String? photoUrl = widget.userData['profilePhotoUrl'];
    if (photoUrl != null && photoUrl.startsWith('/avatars/')) {
      _selectedAvatarId = photoUrl
          .replaceAll('/avatars/', '')
          .replaceAll('.png', '');
    }

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final faculties = await ApiService.getFaculties();
      final avatars = await ApiService.getAvatarOptions();

      // Load all careers from all faculties
      List<Career> allCareers = [];
      for (var faculty in faculties) {
        final careers = await ApiService.getCareersByFaculty(faculty.id);
        allCareers.addAll(careers);
      }

      setState(() {
        _careers = allCareers;
        _avatars = avatars;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.updateUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        semester: int.parse(_semesterController.text),
        careerId: _selectedCareerId!,
        avatarId: _selectedAvatarId,
        calendlyUrl: _calendlyUrlController.text.trim().isNotEmpty
            ? _calendlyUrlController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _semesterController.dispose();
    _calendlyUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF66B2A8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Selection
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Foto de perfil',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                _showAvatarPicker();
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: const Color(0xFFE8F5F3),
                                    backgroundImage: _selectedAvatarId != null
                                        ? NetworkImage(
                                            '${ApiService.baseUrl}/avatars/$_selectedAvatarId.png',
                                          )
                                        : null,
                                    child: _selectedAvatarId == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Color(0xFF66B2A8),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF66B2A8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // First Name
                      Text(
                        'Nombre',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu nombre',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFE8F5F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      Text(
                        'Apellido',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu apellido',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFE8F5F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu apellido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      Text(
                        'Teléfono',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu teléfono (opcional)',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFE8F5F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Calendly URL
                      Text(
                        'Calendly URL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _calendlyUrlController,
                        decoration: InputDecoration(
                          hintText: 'https://calendly.com/tu-usuario',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFE8F5F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.startsWith('http')) {
                              return 'Ingresa una URL válida';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Semester
                      Text(
                        'Semestre',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _semesterController,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu semestre',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFE8F5F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu semestre';
                          }
                          final semester = int.tryParse(value);
                          if (semester == null ||
                              semester < 1 ||
                              semester > 12) {
                            return 'Ingresa un semestre válido (1-12)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Career
                      Text(
                        'Carrera',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCareerId,
                        decoration: InputDecoration(
                          hintText: 'Selecciona tu carrera',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFE8F5F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(color: Colors.black),
                        items: _careers.map((career) {
                          return DropdownMenuItem(
                            value: career.id,
                            child: Text(career.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCareerId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona tu carrera';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Save Button :
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF66B2A8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                                  'Guardar Cambios',
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
            ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona un avatar',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final isSelected = _selectedAvatarId == avatar.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarId = avatar.id;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE85D75)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFE8F5F3),
                          backgroundImage: NetworkImage(
                            '${ApiService.baseUrl}${avatar.url}',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
