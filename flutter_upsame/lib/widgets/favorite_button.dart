import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FavoriteButton extends StatefulWidget {
  final String userId;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.userId,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await ApiService.isFavorite(widget.userId);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (_isFavorite) {
        await ApiService.removeFavorite(widget.userId);
      } else {
        await ApiService.addFavorite(widget.userId);
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? 'Agregado a favoritos'
                  : 'Eliminado de favoritos',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Extract clean error message
        String errorMessage = 'Error al agregar favorito';
        Color backgroundColor = Colors.red;
        
        String errorStr = e.toString();
        
        // Check for specific backend messages
        if (errorStr.contains('No puedes agregarte a ti mismo como favorito') || 
            errorStr.contains('cannot add yourself')) {
          errorMessage = 'No puedes agregarte a ti mismo como favorito';
          backgroundColor = Colors.orange;
        } else if (errorStr.contains('XMLHttpRequest')) {
          errorMessage = 'No se puede conectar al servidor. Verifica que el backend esté corriendo.';
        } else if (errorStr.contains('404')) {
          errorMessage = 'Endpoint no encontrado (404). Verifica la configuración del backend.';
        } else if (errorStr.contains('500')) {
          errorMessage = 'Error del servidor (500). Revisa los logs del backend.';
        } else if (errorStr.contains('): ')) {
          // Extract message after "): " to get the backend message
          int messageStart = errorStr.indexOf('): ') + 3;
          if (messageStart > 2 && messageStart < errorStr.length) {
            errorMessage = errorStr.substring(messageStart);
            // If it's a user error (400), use orange instead of red
            if (errorStr.contains('(400)') || errorStr.contains('(403)')) {
              backgroundColor = Colors.orange;
            }
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite
            ? (widget.activeColor ?? Colors.red[400])
            : (widget.inactiveColor ?? Colors.white),
      ),
      onPressed: _toggleFavorite,
      tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
    );
  }
}
