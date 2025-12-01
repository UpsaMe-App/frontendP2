import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../widgets/avatar_selector.dart';
import '../utils/token_manager.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
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
  Uint8List? _profilePhotoBytes;
  String? _selectedAvatarId = 'baby'; // Preseleccionar avatar por defecto

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // UPSA Green Colors - igual que login
  final Color _greenDark = const Color(0xFF1B5E20);
  final Color _green = const Color(0xFF2E7D32);
  final Color _greenMedium = const Color(0xFF388E3C);
  final Color _greenLight = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    _loadFaculties();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _semesterController.dispose();
    _animationController.dispose();
    super.dispose();
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
        _showSnackBar('Error al cargar facultades: $e', isError: true);
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
        _showSnackBar('Error al cargar carreras: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCareer == null) {
      _showSnackBar('Por favor selecciona una carrera', isError: true);
      return;
    }

    // Debug: Verificar estado antes de validación
    print('🔍 VALIDACIÓN AVATAR:');
    print('  _selectedAvatarId: $_selectedAvatarId');
    print('  _profilePhoto: $_profilePhoto');
    print('  _profilePhotoBytes: $_profilePhotoBytes');

    // Validar que se haya seleccionado un avatar o una foto
    // Si no hay avatar seleccionado, usar 'baby' por defecto
    if (_selectedAvatarId == null &&
        _profilePhoto == null &&
        _profilePhotoBytes == null) {
      setState(() {
        _selectedAvatarId = 'baby';
      });
      print('📱 REGISTER: Usando avatar por defecto: baby');
    }

    setState(() => _isLoading = true);

    try {
      // Debug logs para verificar qué se está enviando
      print('========================================');
      print('REGISTRO - DATOS DE AVATAR');
      print('========================================');
      print('AvatarId seleccionado: $_selectedAvatarId');
      print('AvatarId es null: ${_selectedAvatarId == null}');
      print('AvatarId es vacío: ${_selectedAvatarId?.isEmpty ?? true}');
      print('Archivo de foto: $_profilePhoto');
      print(
        'Bytes de foto: ${_profilePhotoBytes != null ? '${_profilePhotoBytes!.length} bytes' : 'null'}',
      );
      print('========================================');

      await ApiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        careerId: _selectedCareer!.id,
        semester: int.parse(_semesterController.text.trim()),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        avatarId: _selectedAvatarId,
        profilePhoto: _profilePhoto,
        profilePhotoBytes: _profilePhotoBytes,
      );

      if (!mounted) return;

      await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      TokenManager.startTokenRefresh();

      _showSnackBar('¡Registro exitoso! Bienvenido a UpsaMe');

      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: 'user-id-placeholder',
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_greenDark, _green, _greenMedium, _greenLight],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 40,
                vertical: 20,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildRegisterCard(isMobile),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard(bool isMobile) {
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 460),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.90),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _greenDark.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(isMobile),
                  SizedBox(height: isMobile ? 24 : 28),
                  _buildAvatarSection(),
                  // Debug info para mostrar qué avatar está seleccionado
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Avatar seleccionado: ${_selectedAvatarId ?? 'baby'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionDivider('Información Personal'),
                  const SizedBox(height: 16),
                  _buildNameFields(),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24),
                  _buildSectionDivider('Información Académica'),
                  const SizedBox(height: 16),
                  _buildFacultyDropdown(),
                  const SizedBox(height: 16),
                  _buildCareerDropdown(),
                  const SizedBox(height: 16),
                  _buildSemesterAndPhoneFields(),
                  const SizedBox(height: 28),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                  const SizedBox(height: 12),
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [_greenDark, _greenMedium, _greenLight],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Text(
            'Crear Cuenta',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 32 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Únete a la comunidad universitaria',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 14 : 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return AvatarSelector(
      initialAvatarUrl: '/avatars/baby.png', // URL del avatar preseleccionado
      onAvatarSelected: (avatarId) {
        // Ahora recibimos directamente el ID del avatar
        print('📱 REGISTER: Avatar seleccionado: $avatarId');
        setState(() {
          _selectedAvatarId = avatarId ?? 'baby'; // Fallback a baby si es null
          _profilePhoto = null;
          _profilePhotoBytes = null;
        });
        print(
          '📱 REGISTER: _selectedAvatarId actualizado a: $_selectedAvatarId',
        );
      },
      onImageSelected: (file) {
        setState(() {
          _profilePhoto = file;
          _selectedAvatarId = null;
          _profilePhotoBytes = null;
        });
      },
      onImageBytesSelected: (bytes) {
        setState(() {
          _profilePhotoBytes = bytes;
          if (bytes != null) {
            _selectedAvatarId =
                null; // Solo limpiar avatar si se seleccionó una imagen
          }
        });
      },
    );
  }

  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _green.withOpacity(0.3)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _green,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_green.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _firstNameController,
            label: 'Nombre',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: _lastNameController,
            label: 'Apellido',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: 'Correo universitario',
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
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      label: 'Contraseña',
      icon: Icons.lock_outline_rounded,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.grey[600],
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (value.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      controller: _confirmPasswordController,
      label: 'Confirmar contraseña',
      icon: Icons.lock_outline_rounded,
      obscureText: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.grey[600],
          size: 20,
        ),
        onPressed: () =>
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
    );
  }

  Widget _buildFacultyDropdown() {
    return _buildDropdown<Faculty>(
      label: 'Facultad',
      value: _selectedFaculty,
      items: _faculties,
      onChanged: (Faculty? faculty) {
        setState(() {
          _selectedFaculty = faculty;
          _selectedCareer = null;
          _careers = [];
        });
        if (faculty != null) _loadCareers(faculty.id);
      },
      itemLabel: (faculty) => faculty.name,
      isLoading: _loadingFaculties,
      icon: Icons.account_balance_rounded,
    );
  }

  Widget _buildCareerDropdown() {
    return _buildDropdown<Career>(
      label: 'Carrera',
      value: _selectedCareer,
      items: _careers,
      onChanged: (Career? career) {
        setState(() => _selectedCareer = career);
      },
      itemLabel: (career) => career.name,
      isLoading: _loadingCareers,
      enabled: _selectedFaculty != null,
      icon: Icons.school_rounded,
    );
  }

  Widget _buildSemesterAndPhoneFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _semesterController,
            label: 'Semestre',
            icon: Icons.calendar_today_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              final semester = int.tryParse(value);
              if (semester == null || semester < 1 || semester > 12) {
                return '1-12';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: _phoneController,
            label: 'Teléfono (opcional)',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _green, size: 18),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        errorStyle: GoogleFonts.poppins(fontSize: 11),
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
    required IconData icon,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _green, size: 18),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _green, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: isLoading
          ? null
          : items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 250, // Limitar ancho para evitar overflow
                  ),
                  child: Text(
                    itemLabel(item),
                    style: GoogleFonts.poppins(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
      onChanged: enabled && !isLoading ? onChanged : null,
      hint: Text(
        isLoading ? 'Cargando...' : 'Selecciona $label',
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(14),
      icon: Icon(Icons.arrow_drop_down_rounded, color: _green, size: 24),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: _greenLight.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 0),
            spreadRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          disabledBackgroundColor: _green.withOpacity(0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CREAR CUENTA',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Inicia sesión',
            style: GoogleFonts.poppins(
              color: _green,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      },
      icon: Icon(Icons.arrow_back_rounded, color: Colors.grey[600], size: 16),
      label: Text(
        'Volver al inicio',
        style: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
