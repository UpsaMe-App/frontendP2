import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/models.dart';

class AvatarSelector extends StatefulWidget {
  final Function(String?) onAvatarSelected;
  final Function(File?) onImageSelected;
  final Function(Uint8List?)? onImageBytesSelected;
  final String? initialAvatarUrl;

  const AvatarSelector({
    super.key,
    required this.onAvatarSelected,
    required this.onImageSelected,
    this.onImageBytesSelected,
    this.initialAvatarUrl,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  List<Avatar> _avatars = [];
  bool _isLoading = false;
  String? _selectedAvatarId;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAvatars();

    // Si hay un initialAvatarUrl, establecer el ID correspondiente
    if (widget.initialAvatarUrl != null) {
      final avatarId = widget.initialAvatarUrl!
          .replaceAll('/avatars/', '')
          .replaceAll('.png', '');
      _selectedAvatarId = avatarId;
      print('🔸 Avatar inicial establecido: $avatarId');

      // Notificar inmediatamente al padre
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onAvatarSelected(avatarId);
          print('🔸 Callback inicial ejecutado para: $avatarId');
        }
      });
    }
  }

  Future<void> _loadAvatars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final avatars = await ApiService.getAvatarOptions();
      print('🔸 Avatares cargados: ${avatars.length}');
      for (final avatar in avatars) {
        print(
          '  - ID: ${avatar.id}, Label: ${avatar.label}, URL: ${avatar.url}',
        );
      }

      // Variables para determinar si debemos preseleccionar
      // Solo preseleccionar si no hay avatar inicial y no hay nada seleccionado
      final shouldPreselect =
          widget.initialAvatarUrl == null &&
          _selectedAvatarId == null &&
          _selectedImageBytes == null &&
          avatars.isNotEmpty;

      setState(() {
        _avatars = avatars;
        _isLoading = false;

        // Preseleccionar el primer avatar por defecto si no hay selección previa
        if (shouldPreselect) {
          _selectedAvatarId = avatars[0].id;
          print('🔸 Avatar preseleccionado por defecto: ${avatars[0].id}');
        }
      });

      // Ejecutar callback fuera del setState para evitar problemas
      if (shouldPreselect && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onAvatarSelected(avatars[0].id);
            print('🔸 Callback de preselección ejecutado: ${avatars[0].id}');
          }
        });
      }
    } catch (e) {
      print('❌ Error al cargar avatares: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar avatares: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
          _selectedImageBytes = bytes;
          _selectedAvatarId = null; // Limpiar avatar seleccionado
        });

        // Notificar que se seleccionó una imagen personalizada
        widget.onImageSelected(kIsWeb ? null : File(image.path));
        widget.onImageBytesSelected?.call(bytes);
        widget.onAvatarSelected(null); // Limpiar avatar ID
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectAvatar(Avatar avatar) {
    print(
      '🔸 Avatar seleccionado manualmente: ID=${avatar.id}, Label=${avatar.label}',
    );
    setState(() {
      _selectedAvatarId = avatar.id;
      _selectedImage = null;
      _selectedImageBytes = null;
    });
    print(
      '🔸 Estado interno actualizado, _selectedAvatarId: $_selectedAvatarId',
    );

    // Enviar el ID del avatar, no la URL
    widget.onAvatarSelected(avatar.id);
    widget.onImageSelected(null);
    widget.onImageBytesSelected?.call(null);
    print('🔸 Callbacks ejecutados para avatar: ${avatar.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto de perfil',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A8B82),
          ),
        ),
        const SizedBox(height: 15),

        // Preview
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8F5F3),
              border: Border.all(color: const Color(0xFF66B2A8), width: 3),
            ),
            child: ClipOval(
              child: _selectedImageBytes != null
                  ? (kIsWeb
                        ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                        : Image.file(_selectedImage!, fit: BoxFit.cover))
                  : _selectedAvatarId != null
                  ? Image.network(
                      ApiService.getFullImageUrl(
                        _avatars
                            .firstWhere((a) => a.id == _selectedAvatarId)
                            .url,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF66B2A8),
                        );
                      },
                    )
                  : widget.initialAvatarUrl != null
                  ? Image.network(
                      widget.initialAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF66B2A8),
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF66B2A8),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Upload from device button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file),
            label: Text(
              'Subir desde dispositivo',
              style: GoogleFonts.poppins(),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF66B2A8),
              side: const BorderSide(color: Color(0xFF66B2A8), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        Text(
          'O elige un avatar:',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 10),

        // Avatars grid
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F3),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  final isSelected = _selectedAvatarId == avatar.id;

                  return GestureDetector(
                    onTap: () => _selectAvatar(avatar),
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
                      child: ClipOval(
                        child: Image.network(
                          ApiService.getFullImageUrl(avatar.url),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 20),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
