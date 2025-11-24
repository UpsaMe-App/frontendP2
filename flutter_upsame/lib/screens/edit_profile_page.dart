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

  // 🎨 UPSA vibes – verde verde
  final Color primaryDark = const Color(0xFF2E7D32);
  final Color primary = const Color(0xFF388E3C);
  final Color primaryLight = const Color(0xFFC8E6C9);
  final Color bgSoft = const Color(0xFFF1F8E9);

  @override
  void initState() {
    super.initState();

    // Split fullName into firstName and lastName if available
    String fullName = widget.userData['fullName'] ?? '';
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

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
      _selectedAvatarId =
          photoUrl.replaceAll('/avatars/', '').replaceAll('.png', '');
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
      print('🔄 Guardando cambios del perfil...');
      
      // Update user profile
      final updatedData = await ApiService.updateUser(
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
      
      print('✅ Perfil actualizado exitosamente en el servidor');
      print('📦 Datos retornados: $updatedData');

      // Reload fresh data from server to confirm changes were saved
      final freshUserData = await ApiService.getMe();
      print('🔄 Datos frescos recargados del servidor');
      print('📦 Datos actualizados: $freshUserData');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Return the fresh data to the profile page
        Navigator.pop(context, freshUserData);
      }
    } catch (e) {
      print('❌ Error al actualizar perfil: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey[500],
        fontSize: 13,
      ),
      filled: true,
      fillColor: primaryLight.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryLight.withOpacity(0.8),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryLight.withOpacity(0.8),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primary,
          width: 1.6,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primary.withOpacity(0.4),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                                color: primaryDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _showAvatarPicker,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withOpacity(0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor:
                                          primaryLight.withOpacity(0.7),
                                      backgroundImage: _selectedAvatarId != null
                                          ? NetworkImage(
                                              '${ApiService.baseUrl}/avatars/$_selectedAvatarId.png',
                                            )
                                          : null,
                                      child: _selectedAvatarId == null
                                          ? Icon(
                                              Icons.person,
                                              size: 60,
                                              color: primaryDark,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                primaryDark.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
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
                      const SizedBox(height: 28),

                      // First Name
                      Text(
                        'Nombre',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration('Ingresa tu nombre'),
                        style: GoogleFonts.poppins(fontSize: 14),
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
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDecoration('Ingresa tu apellido'),
                        style: GoogleFonts.poppins(fontSize: 14),
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
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration(
                          'Ingresa tu teléfono (opcional)',
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Calendly URL
                      Text(
                        'Calendly URL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _calendlyUrlController,
                        decoration: _inputDecoration(
                          'https://calendly.com/tu-usuario',
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
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
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _semesterController,
                        decoration: _inputDecoration('Ingresa tu semestre'),
                        style: GoogleFonts.poppins(fontSize: 14),
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
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCareerId,
                        decoration: _inputDecoration('Selecciona tu carrera'),
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        dropdownColor: Colors.white,
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
                      const SizedBox(height: 28),

                      // Save Button :
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: primaryDark.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryDark,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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
                                    'Guardar cambios',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
          decoration: BoxDecoration(
            color: bgSoft,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona un avatar',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                                ? primaryDark
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primary.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: primaryLight.withOpacity(0.7),
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
