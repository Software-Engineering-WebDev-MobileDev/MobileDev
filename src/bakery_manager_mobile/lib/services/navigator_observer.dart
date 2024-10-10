import 'package:bakery_manager_mobile/assets/constants.dart';
import 'package:bakery_manager_mobile/services/session_manager.dart';
import 'package:flutter/material.dart';

// Navigator Observer
class MyNavigatorObserver extends NavigatorObserver {
  VoidCallback? _onReturned;
  final _sessionManager = SessionManager();

  set onReturned(VoidCallback? callback) {
    _onReturned = callback;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    super.didPop(route, previousRoute);
    _onReturned?.call();
    await _checkSession(route);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    super.didPush(route, previousRoute);
    await _checkSession(route);
  }

  Future<void> _checkSession(Route<dynamic> route) async {
    if (route is PageRoute) {
      bool isValid = await _sessionManager.isSessionValid();

      if (!isValid && route.settings.name != registrationPageRoute && route.settings.name != '/login') {
      // If the session is not valid, clear session and redirect to login
        await _sessionManager.clearSession();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigator?.pushReplacementNamed('/login');
        });
      }
    }
  }
}
