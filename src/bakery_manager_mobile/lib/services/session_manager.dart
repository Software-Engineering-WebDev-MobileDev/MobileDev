import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class SessionManager {
  final _storage = const FlutterSecureStorage();
  final Duration sessionTimeout = const Duration(hours: 8);
  final Duration idleTimeout = const Duration(minutes: 15);
  Timer? _idleTimer;

  VoidCallback? onIdleTimeout;

  Future<void> saveSession(String sessionId) async {
    await _storage.write(key: 'session_token', value: sessionId);
    await _storage.write(
        key: 'session_start_time', value: DateTime.now().toIso8601String());
  }

  Future<String?> getSessionToken() async {
    return await _storage.read(key: 'session_token');
  }

  Future<DateTime?> getSessionStartTime() async {
    String? startTimeString = await _storage.read(key: 'session_start_time');
    if (startTimeString != null) {
      return DateTime.parse(startTimeString);
    }
    return null;
  }

  Future<void> clearSession() async {
    await ApiService.logout();
    await _storage.delete(key: 'session_token');
    await _storage.delete(key: 'session_start_time');
    stopIdleTimer();
  }

  Future<bool> isSessionValid() async {
    final sessionID = await getSessionToken();
    final sessionStartTime = await getSessionStartTime();

    if (sessionID == null || sessionStartTime == null) {
      return false; // No token or session start time, session is invalid
    }

    // Check if the current time exceeds the session timeout duration
    final now = DateTime.now();
    final sessionTotalDuration = now.difference(sessionStartTime);

    if (sessionTotalDuration > sessionTimeout) {
      return false; // Session has expired
    }

    //SessionID is not vaild on backend
    if (await ApiService.sessionValidate(sessionID) == true) {
      return true;
    } else {
      return false;
    }
    // Session is still valid
  }
  // --- Idle Timeout Management ---

  // Reset the idle timeout timer
  void resetIdleTimer() {
    _idleTimer?.cancel(); // Cancel any existing idle timer
    _idleTimer =
        Timer(idleTimeout, _handleIdleTimeout); // Start a new idle timer
  }

  // Handle session timeout due to inactivity
  void _handleIdleTimeout() {
    if (onIdleTimeout != null) {
      onIdleTimeout!(); // Trigger the idle timeout callback
    }
    clearSession(); // Clear session due to inactivity
  }

  // Stop the idle timeout timer
  void stopIdleTimer() {
    _idleTimer?.cancel();
  }
}
