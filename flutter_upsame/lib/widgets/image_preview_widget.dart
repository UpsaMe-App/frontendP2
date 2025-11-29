import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'safe_image_widget.dart';

/// Widget para mostrar preview de imagen seleccionada
/// antes de subirla al servidor
class ImagePreviewWidget extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? imageFileName;
  final VoidCallback? onRemove;
  final double height;
  final double borderRadius;

  const ImagePreviewWidget({
    super.key,
    this.imageFile,
    this.imageBytes,
    this.imageFileName,
    this.onRemove,
    this.height = 200,
    this.borderRadius = 12,
  }) : assert(
          imageFile != null || imageBytes != null,
          'Debe proporcionar imageFile o imageBytes',
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: SafeImageWidget(
              file: !kIsWeb ? imageFile : null,
              bytes: imageBytes,
              fit: BoxFit.contain,
              borderRadius: 0, // Ya tiene ClipRRect padre
            ),
          ),

          // Nombre del archivo (opcional)
          if (imageFileName != null)
            Positioned(
              bottom: 8,
              left: 8,
              right: onRemove != null ? 48 : 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  imageFileName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          // Botón de eliminar
          if (onRemove != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget para mostrar galería de múltiples imágenes con preview
class MultiImagePreviewWidget extends StatelessWidget {
  final List<Uint8List> imageBytesList;
  final List<String>? imageFileNames;
  final Function(int index)? onRemoveAt;
  final double itemHeight;
  final int crossAxisCount;

  const MultiImagePreviewWidget({
    super.key,
    required this.imageBytesList,
    this.imageFileNames,
    this.onRemoveAt,
    this.itemHeight = 120,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBytesList.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: imageBytesList.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SafeImageWidget(
                  bytes: imageBytesList[index],
                  fit: BoxFit.cover,
                  borderRadius: 0,
                ),
              ),
              if (onRemoveAt != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemoveAt!(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget compacto para mostrar preview en inputs de formulario
class CompactImagePreview extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final String? placeholderText;

  const CompactImagePreview({
    super.key,
    this.imageFile,
    this.imageBytes,
    this.onTap,
    this.onRemove,
    this.placeholderText,
  });

  bool get _hasImage => imageFile != null || imageBytes != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasImage ? Colors.green : Colors.grey[300]!,
            width: _hasImage ? 2 : 1,
          ),
        ),
        child: _hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SafeImageWidget(
                      file: !kIsWeb ? imageFile : null,
                      bytes: imageBytes,
                      fit: BoxFit.cover,
                      borderRadius: 0,
                    ),
                  ),
                  if (onRemove != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, 
                    size: 40, 
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    placeholderText ?? 'Seleccionar imagen',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Ejemplo de uso en un formulario
class ImageUploadFormExample extends StatefulWidget {
  const ImageUploadFormExample({super.key});

  @override
  State<ImageUploadFormExample> createState() => _ImageUploadFormExampleState();
}

class _ImageUploadFormExampleState extends State<ImageUploadFormExample> {
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageFileName;

  Future<void> _pickImage() async {
    // Implementa tu lógica de ImagePicker aquí
    // Este es solo un ejemplo de estructura
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _imageBytes = null;
      _imageFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Opción 1: Preview completo con detalles
        if (_imageBytes != null || _imageFile != null)
          ImagePreviewWidget(
            imageFile: _imageFile,
            imageBytes: _imageBytes,
            imageFileName: _imageFileName,
            onRemove: _removeImage,
            height: 200,
          ),

        // Opción 2: Preview compacto dentro de un input
        CompactImagePreview(
          imageFile: _imageFile,
          imageBytes: _imageBytes,
          onTap: _pickImage,
          onRemove: _imageBytes != null || _imageFile != null 
            ? _removeImage 
            : null,
          placeholderText: 'Toca para agregar imagen',
        ),

        const SizedBox(height: 16),

        // Botón para seleccionar
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Seleccionar Imagen'),
        ),
      ],
    );
  }
}
