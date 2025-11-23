import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/token_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Iniciar el refresh automático del token
      TokenManager.startTokenRefresh();

      // Obtener el userId de la respuesta
      await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Navegar al MainLayout
      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: 'user-id-placeholder', // TODO: Obtener el userId real del login response
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A5C36),
              Color(0xFF1E8449),
              Color(0xFF27AE60),
              Color(0xFF2ECC71),
            ],
            stops: [0.1, 0.4, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 450,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo/Title with beautiful gradient
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [
                            Color(0xFF0A5C36),
                            Color(0xFF1E8449),
                            Color(0xFF27AE60),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'UpsaMe',
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Inicia sesión en tu cuenta',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey[600],
                        ),
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
                            color: Color(0xFF27AE60),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
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
                    const SizedBox(height: 25),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: Colors.grey[600],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                            color: Color(0xFF27AE60),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 35),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE85D75),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
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
                                'INICIAR SESIÓN',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta? ',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Regístrate',
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
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: const Color(0xFF1E8449),
                      ),
                      label: Text(
                        'Volver al inicio',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E8449),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}