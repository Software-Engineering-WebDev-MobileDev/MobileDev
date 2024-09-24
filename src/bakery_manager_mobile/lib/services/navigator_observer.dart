import 'package:flutter/material.dart';

// Navigator Observer
class MyNavigatorObserver extends NavigatorObserver {
  VoidCallback? _onReturned;

  set onReturned(VoidCallback? callback) {
    _onReturned = callback;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _onReturned?.call();
  }
}
