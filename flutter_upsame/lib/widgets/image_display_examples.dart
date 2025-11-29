import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'safe_image_widget.dart';

/// Ejemplos completos de cómo mostrar imágenes de manera segura
/// sin overflow, adaptándose a cualquier tamaño

// ============================================================
// EJEMPLO 1: Imagen de red (URL) con bordes redondeados
// ============================================================
class NetworkImageExample extends StatelessWidget {
  final String imageUrl;

  const NetworkImageExample({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SafeImageWidget(
      url: imageUrl,
      fit: BoxFit.cover, // Cubre todo el espacio disponible
      borderRadius: 16,
      maxHeight: 400, // Altura máxima
    );
  }
}

// ============================================================
// EJEMPLO 2: Imagen de archivo (File) con aspect ratio fijo
// ============================================================
class FileImageExample extends StatelessWidget {
  final File imageFile;

  const FileImageExample({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return SafeImageWidget(
      file: imageFile,
      fit: BoxFit.contain, // Mantiene dentro sin recortar
      borderRadius: 12,
      aspectRatio: 16 / 9, // Ratio fijo 16:9
      optimizeImage: true, // Optimiza la imagen automáticamente
    );
  }
}

// ============================================================
// EJEMPLO 3: Imagen desde bytes (Uint8List) para web
// ============================================================
class BytesImageExample extends StatelessWidget {
  final Uint8List imageBytes;

  const BytesImageExample({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return SafeImageWidget(
      bytes: imageBytes,
      fit: BoxFit.cover,
      borderRadius: 20,
      maxWidth: 600,
      optimizeImage: true, // Reduce resolución si es muy grande
      maxImageDimension: 1920, // Máximo 1920px en cualquier dimensión
    );
  }
}

// ============================================================
// EJEMPLO 4: Galería de imágenes con grid
// ============================================================
class ImageGridExample extends StatelessWidget {
  final List<String> imageUrls;

  const ImageGridExample({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1, // Cuadrados
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return SafeImageWidget(
          url: imageUrls[index],
          fit: BoxFit.cover,
          borderRadius: 12,
        );
      },
    );
  }
}

// ============================================================
// EJEMPLO 5: Imagen de perfil circular
// ============================================================
class CircularProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const CircularProfileImage({
    super.key,
    this.imageUrl,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? SafeImageWidget(
                url: imageUrl!,
                fit: BoxFit.cover,
                borderRadius: 0, // No necesario, ClipOval ya lo hace
              )
            : Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: Colors.grey[600],
                ),
              ),
      ),
    );
  }
}

// ============================================================
// EJEMPLO 6: Banner con imagen de fondo y overlay
// ============================================================
class BannerWithImageBackground extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const BannerWithImageBackground({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          // Imagen de fondo
          SafeImageWidget(
            url: imageUrl,
            fit: BoxFit.cover,
            borderRadius: 16,
          ),
          // Overlay oscuro
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
          // Texto sobre la imagen
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EJEMPLO 7: Card con imagen y texto (como post card)
// ============================================================
class PostCardWithImage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String authorName;
  final String? authorAvatar;

  const PostCardWithImage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.authorName,
    this.authorAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con autor
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircularProfileImage(
                  imageUrl: authorAvatar,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Imagen del post
          SafeImageWidget(
            url: imageUrl,
            fit: BoxFit.cover,
            borderRadius: 0,
            aspectRatio: 16 / 9,
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EJEMPLO 8: Carrusel de imágenes con PageView
// ============================================================
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SafeImageWidget(
                  url: widget.imageUrls[index],
                  fit: BoxFit.cover,
                  borderRadius: 16,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
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
// EJEMPLO 9: Imagen con zooming (fullscreen)
// ============================================================
class ZoomableImageViewer extends StatelessWidget {
  final String imageUrl;

  const ZoomableImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullscreenImageViewer(imageUrl: imageUrl),
          ),
        );
      },
      child: SafeImageWidget(
        url: imageUrl,
        fit: BoxFit.cover,
        borderRadius: 12,
        maxHeight: 400,
      ),
    );
  }
}

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            url: imageUrl,
            fit: BoxFit.contain,
            borderRadius: 0,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EJEMPLO 10: Uso completo en una página real
// ============================================================
class CompleteImageExamplePage extends StatelessWidget {
  const CompleteImageExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplos de Imágenes Seguras'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Imagen de red básica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const NetworkImageExample(
              imageUrl: 'https://picsum.photos/800/600',
            ),
            const SizedBox(height: 24),

            const Text(
              'Grid de imágenes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ImageGridExample(
              imageUrls: List.generate(
                6,
                (i) => 'https://picsum.photos/400/400?random=$i',
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Banner con overlay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const BannerWithImageBackground(
              imageUrl: 'https://picsum.photos/1200/400',
              title: 'Título del Banner',
              subtitle: 'Subtítulo descriptivo',
            ),
            const SizedBox(height: 24),

            const Text(
              'Carrusel de imágenes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ImageCarousel(
              imageUrls: List.generate(
                5,
                (i) => 'https://picsum.photos/800/400?random=${i + 10}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
