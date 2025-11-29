import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Widget seguro para mostrar imágenes sin overflow
/// Maneja cualquier tamaño de imagen y se adapta automáticamente
/// GARANTIZA que nunca cause overflow en cualquier dispositivo
class SafeImageWidget extends StatefulWidget {
  final String? url;
  final Uint8List? bytes;
  final File? file;
  final BoxFit fit;
  final double borderRadius;
  final double? maxWidth;
  final double? maxHeight;
  final double? aspectRatio;
  final bool optimizeImage;
  final int maxImageDimension;

  const SafeImageWidget({
    super.key,
    this.url,
    this.bytes,
    this.file,
    this.fit = BoxFit.cover,
    this.borderRadius = 12.0,
    this.maxWidth,
    this.maxHeight,
    this.aspectRatio,
    this.optimizeImage = true,
    this.maxImageDimension = 1920,
  }) : assert(
          url != null || bytes != null || file != null,
          'Debe proporcionar url, bytes o file',
        );

  @override
  State<SafeImageWidget> createState() => _SafeImageWidgetState();
}

class _SafeImageWidgetState extends State<SafeImageWidget> {
  Uint8List? _optimizedBytes;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.optimizeImage && widget.bytes != null) {
      _optimizeImage();
    } else if (widget.optimizeImage && widget.file != null && !kIsWeb) {
      _optimizeImageFromFile();
    }
  }

  Future<void> _optimizeImage() async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final optimized = await _processImage(widget.bytes!);
      if (mounted) {
        setState(() {
          _optimizedBytes = optimized;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al procesar imagen';
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _optimizeImageFromFile() async {
    if (!mounted || widget.file == null) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final bytes = await widget.file!.readAsBytes();
      final optimized = await _processImage(bytes);
      if (mounted) {
        setState(() {
          _optimizedBytes = optimized;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al procesar imagen';
          _isProcessing = false;
        });
      }
    }
  }

  Future<Uint8List> _processImage(Uint8List bytes) async {
    return await Future(() {
      try {
        // Decodificar la imagen
        final originalImage = img.decodeImage(bytes);
        if (originalImage == null) return bytes;

        // Si la imagen es pequeña, devolverla sin cambios
        if (originalImage.width <= widget.maxImageDimension &&
            originalImage.height <= widget.maxImageDimension) {
          return bytes;
        }

        // Calcular nuevo tamaño manteniendo aspect ratio
        double scale = 1.0;
        if (originalImage.width > originalImage.height) {
          scale = widget.maxImageDimension / originalImage.width;
        } else {
          scale = widget.maxImageDimension / originalImage.height;
        }

        final newWidth = (originalImage.width * scale).round();
        final newHeight = (originalImage.height * scale).round();

        // Redimensionar
        final resized = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );

        // Codificar como JPEG con calidad 85 para mejor compresión
        final optimizedBytes = img.encodeJpg(resized, quality: 85);
        return Uint8List.fromList(optimizedBytes);
      } catch (e) {
        debugPrint('Error al optimizar imagen: $e');
        return bytes;
      }
    });
  }

  Widget _buildImageWidget() {
    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_isProcessing) {
      return _buildLoadingWidget();
    }

    // Usar bytes optimizados si están disponibles
    final imageBytes = _optimizedBytes ?? widget.bytes;

    Widget imageWidget;

    if (widget.url != null) {
      imageWidget = Image.network(
        widget.url!,
        fit: widget.fit,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
      );
    } else if (imageBytes != null) {
      imageWidget = Image.memory(
        imageBytes,
        fit: widget.fit,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (widget.file != null && !kIsWeb) {
      imageWidget = Image.file(
        widget.file!,
        fit: widget.fit,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      return _buildErrorWidget();
    }

    return imageWidget;
  }

  Widget _buildLoadingWidget([ImageChunkEvent? progress]) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          value: progress != null && progress.expectedTotalBytes != null
              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error al cargar imagen',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Obtener el ancho máximo disponible
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // Determinar el ancho efectivo
        double effectiveWidth = availableWidth;
        if (widget.maxWidth != null && widget.maxWidth! < availableWidth) {
          effectiveWidth = widget.maxWidth!;
        }

        // Construir el widget de imagen
        Widget child = _buildImageWidget();

        // Envolver en ClipRRect para bordes redondeados
        child = ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: child,
        );

        // Aplicar AspectRatio si está definido
        if (widget.aspectRatio != null) {
          child = AspectRatio(
            aspectRatio: widget.aspectRatio!,
            child: child,
          );
        }

        // Aplicar constraints de altura si está definido
        if (widget.maxHeight != null) {
          child = ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.maxHeight!,
            ),
            child: child,
          );
        }

        // CLAVE: Usar SizedBox con width específico para evitar overflow
        return SizedBox(
          width: effectiveWidth,
          child: child,
        );
      },
    );
  }
}

/// Función de utilidad para procesar imágenes antes de mostrarlas
/// Reduce la resolución si es demasiado grande
Future<Uint8List> processAndOptimizeImage(
  Uint8List bytes, {
  int maxDimension = 1920,
  int quality = 85,
}) async {
  return await Future(() {
    try {
      // Decodificar
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return bytes;

      // Si es pequeña, retornar sin cambios
      if (originalImage.width <= maxDimension &&
          originalImage.height <= maxDimension) {
        return bytes;
      }

      // Calcular escala manteniendo aspect ratio
      double scale = 1.0;
      if (originalImage.width > originalImage.height) {
        scale = maxDimension / originalImage.width;
      } else {
        scale = maxDimension / originalImage.height;
      }

      final newWidth = (originalImage.width * scale).round();
      final newHeight = (originalImage.height * scale).round();

      // Redimensionar con interpolación de alta calidad
      final resized = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Codificar como JPEG con calidad especificada
      final optimizedBytes = img.encodeJpg(resized, quality: quality);
      return Uint8List.fromList(optimizedBytes);
    } catch (e) {
      debugPrint('Error optimizando imagen: $e');
      return bytes;
    }
  });
}
