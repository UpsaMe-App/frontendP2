/// CÓDIGO DE REFERENCIA RÁPIDA - SafeImageWidget
/// Copia y pega estos ejemplos según tu necesidad

// ============================================================
// ESCENARIO 1: Post Detail Page (mostrar imagen completa)
// ============================================================

// En tu post_detail_page.dart (YA IMPLEMENTADO ✅)
SafeImageWidget(
  url: '${ApiService.baseUrl}${widget.post.imageUrl}',
  fit: BoxFit.contain,  // Muestra toda la imagen sin recortar
  borderRadius: 12,
  optimizeImage: false, // Ya viene optimizada del servidor
)

// ============================================================
// ESCENARIO 2: Post Card en Home (lista de posts)
// ============================================================

// Para cards uniformes en la lista
SafeImageWidget(
  url: '${ApiService.baseUrl}${post.imageUrl}',
  fit: BoxFit.cover,    // Llena todo el espacio uniformemente
  aspectRatio: 16 / 9,  // Ratio fijo para todas las cards
  borderRadius: 12,
  maxHeight: 200,       // Opcional: altura máxima
)

// ============================================================
// ESCENARIO 3: Avatar de Usuario (circular)
// ============================================================

// En cualquier lugar que muestres avatar
SizedBox(
  width: 80,
  height: 80,
  child: ClipOval(
    child: SafeImageWidget(
      url: '${ApiService.baseUrl}${user.photoUrl}',
      fit: BoxFit.cover,
      borderRadius: 0, // No necesario con ClipOval
    ),
  ),
)

// O con fallback si no hay foto:
CircleAvatar(
  radius: 40,
  backgroundColor: Colors.grey[300],
  backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
      ? NetworkImage('${ApiService.baseUrl}${user.photoUrl}')
      : null,
  child: user.photoUrl == null || user.photoUrl!.isEmpty
      ? Icon(Icons.person, size: 40, color: Colors.grey[600])
      : null,
)

// ============================================================
// ESCENARIO 4: Subir Imagen (Crear/Editar Post)
// ============================================================

import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';

class CreatePostPage extends StatefulWidget {
  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageFileName;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,   // Limita tamaño al seleccionar
        maxHeight: 1920,
        imageQuality: 85, // Calidad 85%
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (!kIsWeb) {
            _imageFile = File(image.path);
          }
          _imageBytes = bytes;
          _imageFileName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
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
      children: [
        // Botón para seleccionar imagen
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text('Seleccionar Imagen'),
        ),

        SizedBox(height: 16),

        // Preview de la imagen seleccionada
        if (_imageBytes != null || _imageFile != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                SafeImageWidget(
                  file: !kIsWeb ? _imageFile : null,
                  bytes: _imageBytes,
                  fit: BoxFit.contain,
                  borderRadius: 12,
                ),
                // Botón para eliminar
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Al enviar el post
  Future<void> _submitPost() async {
    await ApiService.createPost(
      title: titleController.text,
      content: contentController.text,
      image: kIsWeb ? null : _imageFile,
      imageBytes: _imageBytes,
      imageFileName: _imageFileName,
    );
  }
}

// ============================================================
// ESCENARIO 5: Galería de Imágenes (Grid)
// ============================================================

GridView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,      // 3 columnas
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1,     // Cuadrados
  ),
  itemCount: imageUrls.length,
  itemBuilder: (context, index) {
    return GestureDetector(
      onTap: () => _openImageFullscreen(imageUrls[index]),
      child: SafeImageWidget(
        url: '${ApiService.baseUrl}${imageUrls[index]}',
        fit: BoxFit.cover,
        borderRadius: 8,
      ),
    );
  },
)

// ============================================================
// ESCENARIO 6: Imagen Fullscreen con Zoom
// ============================================================

void _openImageFullscreen(String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: SafeImageWidget(
              url: '${ApiService.baseUrl}$imageUrl',
              fit: BoxFit.contain,
              borderRadius: 0,
            ),
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// ESCENARIO 7: Banner/Header con Imagen de Fondo
// ============================================================

Stack(
  children: [
    // Imagen de fondo
    SafeImageWidget(
      url: '${ApiService.baseUrl}${bannerImageUrl}',
      fit: BoxFit.cover,
      aspectRatio: 21 / 9, // Banner ancho
      borderRadius: 0,
    ),
    // Overlay oscuro
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
    ),
    // Contenido sobre la imagen
    Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Título',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Descripción del banner',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    ),
  ],
)

// ============================================================
// ESCENARIO 8: Carrusel de Imágenes (PageView)
// ============================================================

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarousel({Key? key, required this.imageUrls}) : super(key: key);

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SafeImageWidget(
                  url: '${ApiService.baseUrl}${widget.imageUrls[index]}',
                  fit: BoxFit.cover,
                  borderRadius: 16,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12),
        // Indicadores de página
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.blue
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ESCENARIO 9: Optimizar Imagen ANTES de Subir al Servidor
// ============================================================

import 'package:flutter_upsame/widgets/safe_image_widget.dart';

Future<void> _uploadOptimizedImage() async {
  // 1. Seleccionar imagen
  final XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );

  if (image == null) return;

  // 2. Leer bytes
  final originalBytes = await image.readAsBytes();

  // 3. Optimizar (reduce tamaño 60-80%)
  final optimizedBytes = await processAndOptimizeImage(
    originalBytes,
    maxDimension: 1920, // Max 1920px en cualquier lado
    quality: 85,        // 85% calidad JPEG
  );

  // 4. Subir al servidor
  await ApiService.uploadImage(
    optimizedBytes,
    fileName: image.name,
  );

  print('Tamaño original: ${originalBytes.length} bytes');
  print('Tamaño optimizado: ${optimizedBytes.length} bytes');
  print('Ahorro: ${((1 - optimizedBytes.length / originalBytes.length) * 100).toStringAsFixed(1)}%');
}

// ============================================================
// ESCENARIO 10: Imagen con Placeholder mientras Carga
// ============================================================

// Opción simple (usando SafeImageWidget que ya tiene loading state)
SafeImageWidget(
  url: '${ApiService.baseUrl}${imageUrl}',
  fit: BoxFit.cover,
  borderRadius: 12,
  // El widget ya muestra un CircularProgressIndicator mientras carga
)

// Opción con placeholder personalizado
class ImageWithPlaceholder extends StatelessWidget {
  final String imageUrl;

  const ImageWithPlaceholder({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Error al cargar imagen', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// TIPS ADICIONALES
// ============================================================

// TIP 1: Si la imagen no aparece, verifica la URL
debugPrint('Image URL: ${ApiService.baseUrl}${imageUrl}');

// TIP 2: Para web, asegúrate que el servidor permita CORS
// En tu backend (ASP.NET):
// app.UseCors(policy => policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());

// TIP 3: Para Android, agrega permisos de internet en AndroidManifest.xml
// <uses-permission android:name="android.permission.INTERNET"/>

// TIP 4: Usa BoxFit.cover para thumbnails uniformes
// Usa BoxFit.contain para mostrar imagen completa

// TIP 5: Siempre optimiza imágenes antes de subirlas al servidor
// Ahorra bandwidth, storage y mejora UX
