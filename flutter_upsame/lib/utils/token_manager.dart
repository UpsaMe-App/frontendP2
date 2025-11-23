import 'dart:async';
import '../services/api_service.dart';

class TokenManager {
  static Timer? _refreshTimer;
  static DateTime? _lastRefresh;
  static const Duration _refreshInterval = Duration(minutes: 55); // Refrescar antes de 60 min
  
  static void startTokenRefresh() {
    _lastRefresh = DateTime.now();
    _cancelRefreshTimer();
    
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) async {
      await _refreshToken();
    });
  }
  
  static Future<void> _refreshToken() async {
    try {
      await ApiService.refreshToken();
      _lastRefresh = DateTime.now();
      print('Token refreshed successfully at ${_lastRefresh}');
    } catch (e) {
      print('Error refreshing token: $e');
      // Si falla el refresh, detener el timer y el usuario tendrá que volver a loguearse
      stopTokenRefresh();
    }
  }
  
  static void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  static void stopTokenRefresh() {
    _cancelRefreshTimer();
    _lastRefresh = null;
    ApiService.clearTokens();
  }
  
  static bool get isActive => _refreshTimer != null && _refreshTimer!.isActive;
  
  static DateTime? get lastRefreshTime => _lastRefresh;
}
