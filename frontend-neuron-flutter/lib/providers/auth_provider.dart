import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  User? _user;
  UserProfileModel? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider({
    AuthService? authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? AuthService(),
        _firestore = firestore ?? FirebaseFirestore.instance {
    _init();
  }

  // --- Getters ---
  User? get user => _user;
  UserProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  String? get uid => _user?.uid;
  String? get email => _user?.email;
  String get displayName => _userProfile?.displayName ?? _user?.displayName ?? email?.split('@').first ?? 'User';
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _init() {
    _isLoading = true;
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      _user = firebaseUser;
      if (firebaseUser != null) {
        await _fetchOrCreateProfile(firebaseUser);
      } else {
        _userProfile = null;
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _isLoading = false;
      _errorMessage = AuthService.mapAuthError(err);
      notifyListeners();
    });
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Sign In with Email & Password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final cred = await _authService.signIn(email: email, password: password);
      _user = cred.user;
      if (_user != null) {
        await _fetchOrCreateProfile(_user!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = AuthService.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  /// Register with Email, Password, and Confirm Password
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    _errorMessage = null;
    _successMessage = null;

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match.';
      notifyListeners();
      return false;
    }

    final passError = AuthService.validatePassword(password);
    if (passError != null) {
      _errorMessage = passError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final cred = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      _user = cred.user;
      if (_user != null) {
        await _fetchOrCreateProfile(_user!, initialDisplayName: displayName);
      }
      _successMessage = 'Account created successfully! Verification email sent.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = AuthService.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  /// Send verification email to currently signed in user
  Future<bool> sendVerificationEmail() async {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _authService.sendEmailVerification();
      _successMessage = 'Verification email sent. Please check your inbox.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AuthService.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  /// Refresh Firebase user to check if email verification succeeded
  Future<bool> checkEmailVerification() async {
    try {
      final verified = await _authService.checkEmailVerified();
      _user = _authService.currentUser;
      notifyListeners();
      return verified;
    } catch (e) {
      _errorMessage = AuthService.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _successMessage = 'If an account exists for $email, a password reset link has been dispatched.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = AuthService.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user and clear local auth state
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _errorMessage = null;
      _successMessage = null;
    } catch (e) {
      _errorMessage = AuthService.mapAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch or create minimal User Profile document under `users/{uid}`
  Future<void> _fetchOrCreateProfile(User firebaseUser, {String? initialDisplayName}) async {
    try {
      final docRef = _firestore.collection('users').doc(firebaseUser.uid);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        _userProfile = UserProfileModel.fromFirestore(snapshot);
      } else {
        final newProfile = UserProfileModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: initialDisplayName ?? firebaseUser.displayName ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          schemaVersion: 1,
        );
        await docRef.set(newProfile.toFirestore());
        _userProfile = newProfile;
      }
    } catch (e) {
      // In offline or restricted network mode, create local fallback profile
      _userProfile = UserProfileModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: initialDisplayName ?? firebaseUser.displayName ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        schemaVersion: 1,
      );
    }
  }

  /// Update user profile display name
  Future<bool> updateDisplayName(String name) async {
    if (_user == null) return false;
    try {
      await _user!.updateDisplayName(name.trim());
      final docRef = _firestore.collection('users').doc(_user!.uid);
      await docRef.set({
        'displayName': name.trim(),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      _userProfile = _userProfile?.copyWith(
        displayName: name.trim(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AuthService.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

