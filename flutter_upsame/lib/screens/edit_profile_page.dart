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

  final Color primaryDark = const Color(0xFF2E7D32);
  final Color primary = const Color(0xFF388E3C);
  final Color primaryLight = const Color(0xFFC8E6C9);
  final Color bgSoft = const Color(0xFFF1F8E9);

  @override
  void initState() {
    super.initState();

    // Initialize controllers with empty values first
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _semesterController = TextEditingController();
    _calendlyUrlController = TextEditingController();

    // Load fresh data from backend
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // IMPORTANTE: Obtener datos frescos del backend en lugar de usar widget.userData
      // que puede estar desactualizado
      print('Cargando datos frescos del perfil desde el backend...');
      final userData = await ApiService.getMe();
      print('Datos del perfil recibidos: $userData');
      
      final faculties = await ApiService.getFaculties();
      final avatars = await ApiService.getAvatarOptions();

      List<Career> allCareers = [];
      for (var faculty in faculties) {
        final careers = await ApiService.getCareersByFaculty(faculty.id);
        allCareers.addAll(careers);
      }

      // Parse user data and populate controllers with FRESH data
      final String firstName = userData['firstName'] ?? '';
      final String lastName = userData['lastName'] ?? '';
      
      _firstNameController.text = firstName;
      _lastNameController.text = lastName;
      _phoneController.text = userData['phone'] ?? '';
      _semesterController.text = userData['semester'] != null 
          ? userData['semester'].toString() 
          : '';
      _calendlyUrlController.text = userData['calendlyUrl'] ?? '';

      _selectedCareerId = userData['careerId'];

      final String? photoUrl = userData['profilePhotoUrl'];
      if (photoUrl != null && photoUrl.startsWith('/avatars/')) {
        _selectedAvatarId = photoUrl.replaceAll('/avatars/', '').replaceAll('.png', '');
      }

      setState(() {
        _careers = allCareers;
        _avatars = avatars;
        _isLoadingData = false;
      });

      print('Datos del perfil cargados y aplicados a los campos');
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoadingData = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCareerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona tu carrera'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int? semesterParsed = int.tryParse(_semesterController.text.trim());
    if (semesterParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semestre inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? calendlyUrl;
    final rawCalendly = _calendlyUrlController.text.trim();
    if (rawCalendly.isNotEmpty) {
      final uri = Uri.tryParse(rawCalendly);
      if (uri == null || (!uri.isAbsolute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingresa una URL válida de Calendly'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      calendlyUrl = rawCalendly;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare phone - send null if empty instead of empty string
      final String? phone = _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim();

      // Debug logging
      print('Guardando perfil con los siguientes datos:');
      print('  - Nombre: ${_firstNameController.text.trim()}');
      print('  - Apellido: ${_lastNameController.text.trim()}');
      print('  - Telefono: $phone');
      print('  - Semestre: $semesterParsed');
      print('  - CarreraId: $_selectedCareerId');
      print('  - AvatarId: $_selectedAvatarId');
      print('  - Calendly: $calendlyUrl');

      await ApiService.updateUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: phone,
        semester: semesterParsed,
        careerId: _selectedCareerId!,
        avatarId: _selectedAvatarId,  // Send null instead of empty string
        calendlyUrl: calendlyUrl,      // Already null if empty
      );

      print('Perfil actualizado exitosamente en el backend');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Error al actualizar perfil: $e');
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: primaryLight.withOpacity(0.7),
                                    backgroundImage: _selectedAvatarId != null
                                        ? NetworkImage(
                                            '${ApiService.baseUrl}/avatars/$_selectedAvatarId.png',
                                          )
                                        : null,
                                    child: _selectedAvatarId == null
                                        ? Icon(Icons.person, size: 60, color: primaryDark)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// NOMBRE
                      Text('Nombre', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration('Ingresa tu nombre'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                      ),

                      const SizedBox(height: 16),

                      /// APELLIDO
                      Text('Apellido', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDecoration('Ingresa tu apellido'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                      ),

                      const SizedBox(height: 16),

                      /// TELÉFONO
                      Text('Teléfono', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration('Teléfono'),
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      /// CALENDLY
                      Text('Calendly URL', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      TextFormField(
                        controller: _calendlyUrlController,
                        decoration: _inputDecoration('https://calendly.com/tu-usuario'),
                      ),

                      const SizedBox(height: 16),

                      /// SEMESTRE
                      Text('Semestre', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      TextFormField(
                        controller: _semesterController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Ingresa tu semestre'),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1 || n > 12) return 'Semestre inválido';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// CARRERA
                      Text('Carrera', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      DropdownButtonFormField<String>(
                        value: _selectedCareerId,
                        decoration: _inputDecoration('Selecciona tu carrera'),
                        items: _careers.map((c) {
                          return DropdownMenuItem(value: c.id, child: Text(c.name));
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCareerId = value),
                        validator: (v) => v == null ? 'Campo requerido' : null,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Guardar cambios'),
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
          color: bgSoft,
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
                  setState(() => _selectedAvatarId = avatar.id);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryDark : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('${ApiService.baseUrl}${avatar.url}'),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
