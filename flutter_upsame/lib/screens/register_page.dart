import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../widgets/avatar_selector.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _semesterController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  List<Faculty> _faculties = [];
  List<Career> _careers = [];
  Faculty? _selectedFaculty;
  Career? _selectedCareer;
  bool _loadingFaculties = false;
  bool _loadingCareers = false;
  File? _profilePhoto;

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  Future<void> _loadFaculties() async {
    setState(() => _loadingFaculties = true);
    try {
      final faculties = await ApiService.getFaculties();
      setState(() {
        _faculties = faculties;
        _loadingFaculties = false;
      });
    } catch (e) {
      setState(() => _loadingFaculties = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar facultades: $e')),
        );
      }
    }
  }

  Future<void> _loadCareers(String facultyId) async {
    setState(() => _loadingCareers = true);
    try {
      final careers = await ApiService.getCareersByFaculty(facultyId);
      setState(() {
        _careers = careers;
        _loadingCareers = false;
      });
    } catch (e) {
      setState(() => _loadingCareers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar carreras: $e')),
        );
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCareer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una carrera')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        careerId: _selectedCareer!.id,
        semester: int.parse(_semesterController.text.trim()),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        profilePhoto: _profilePhoto,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. Por favor inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Crear Cuenta',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E8449),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a la comunidad universitaria',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Avatar Selector
                  AvatarSelector(
                    onAvatarSelected: (_) {}, // No usamos avatar ID en registro por ahora, o podríamos
                    onImageSelected: (file) {
                      setState(() {
                        _profilePhoto = file;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Name Fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'Nombre',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requerido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Apellido',
                          icon: Icons.person_outline,
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
                  const SizedBox(height: 20),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: 'Correo electrónico universitario',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outlined,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF1E8449),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar contraseña',
                    icon: Icons.lock_outlined,
                    obscureText: _obscureConfirmPassword,
                    onFieldSubmitted: (_) => _register(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF1E8449),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Faculty Dropdown
                  _buildDropdown<Faculty>(
                    label: 'Facultad',
                    value: _selectedFaculty,
                    items: _faculties,
                    onChanged: (Faculty? faculty) {
                      setState(() {
                        _selectedFaculty = faculty;
                        _selectedCareer = null;
                        _careers = [];
                      });
                      if (faculty != null) {
                        _loadCareers(faculty.id);
                      }
                    },
                    itemLabel: (faculty) => faculty.name,
                    isLoading: _loadingFaculties,
                  ),
                  const SizedBox(height: 20),

                  // Career Dropdown
                  _buildDropdown<Career>(
                    label: 'Carrera',
                    value: _selectedCareer,
                    items: _careers,
                    onChanged: (Career? career) {
                      setState(() {
                        _selectedCareer = career;
                      });
                    },
                    itemLabel: (career) => career.name,
                    isLoading: _loadingCareers,
                    enabled: _selectedFaculty != null,
                  ),
                  const SizedBox(height: 20),

                  // Semester and Phone in a row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _semesterController,
                          label: 'Semestre',
                          icon: Icons.school_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requerido';
                            }
                            final semester = int.tryParse(value);
                            if (semester == null || semester < 1 || semester > 12) {
                              return 'Entre 1 y 12';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTextField(
                          controller: _phoneController,
                          label: 'Teléfono (opcional)',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE85D75),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFE85D75).withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'REGISTRARSE',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta? ',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Inicia sesión',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1E8449),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Back to home
                  const SizedBox(height: 15),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          '/', 
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1E8449),
                      ),
                      label: Text(
                        'Volver al inicio',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E8449),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[600],
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 20, 163, 79),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) itemLabel,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.arrow_drop_down_circle_outlined,
            color: Colors.grey[600],
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 30, 138, 52),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
        ),
        items: isLoading
            ? null
            : items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
        onChanged: enabled && !isLoading ? onChanged : null,
        hint: Text(
          isLoading ? 'Cargando...' : 'Selecciona $label',
          style: GoogleFonts.poppins(),
        ),
        validator: (value) {
          if (value == null) {
            return 'Por favor selecciona una opción';
          }
          return null;
        },
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(15),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color.fromARGB(255, 9, 189, 84),
        ),
      ),
    );
  }
}