import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Listenable used by GoRouter to refresh when auth state changes.
class AuthRouterNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _sub;
  User? _user = FirebaseAuth.instance.currentUser;

  AuthRouterNotifier() {
    // Keep local cache of current user and notify GoRouter when it changes    
    _sub = FirebaseAuth.instance.authStateChanges().listen((u) {
      _user = u;
      notifyListeners(); // tells GoRouter to re-run redirect()
    });
  }

  bool get isLoggedIn => _user != null;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
