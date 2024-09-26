import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  final _storage = const FlutterSecureStorage();
  final Duration sessionTimeout = const Duration(hours: 8);


  Future<void> saveSession(String sessionId) async {
    await _storage.write(key: 'session_token', value: sessionId);
    await _storage.write(key: 'session_start_time', value: DateTime.now().toIso8601String());
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
    await _storage.delete(key: 'session_token');
    await _storage.delete(key: 'session_start_time');
  }

  Future<bool> isSessionValid() async {
    final sessionID = await getSessionToken();
    final sessionStartTime = await getSessionStartTime();
    
    if (sessionID == null || sessionStartTime == null) {
      return false;  // No token or session start time, session is invalid
    }

    // Check if the current time exceeds the session timeout duration
    final now = DateTime.now();
    final sessionDuration = now.difference(sessionStartTime);

    if (sessionDuration > sessionTimeout) {
      return false;  // Session has expired
    }

    //SessionID is not vaild on backend
    if (await ApiService.sessionValidate(sessionID)) {
      return false;
    }

    return true;  // Session is still valid
  }
}
