import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  FirebaseAuth get rawAuth => _auth;

  /// The currently authenticated Firebase user, or null if unauthenticated.
  User? get currentUser => _auth.currentUser;

  /// Reactive stream of user authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Whether current user has verified their email address.
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Register a new user using email and password.
  /// Enforces validation before calling Firebase.
  Future<UserCredential> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    _validateCredentials(cleanEmail, password);

    final cred = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(displayName.trim());
    }

    // Automatically send verification email upon registration
    try {
      await cred.user?.sendEmailVerification();
    } catch (_) {
      // Don't block registration if the initial email dispatch encounters a transient rate limit
    }

    return cred;
  }

  /// Sign in an existing user with email and password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw const FormatException('Email and password must not be empty.');
    }

    return await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );
  }

  /// Send verification email to the currently logged in user.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user found to verify.');
    }
    await user.sendEmailVerification();
  }

  /// Reload the user and check whether their email is verified.
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Send password reset link to specified email.
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!isValidEmail(cleanEmail)) {
      throw const FormatException('Please enter a valid email address.');
    }
    await _auth.sendPasswordResetEmail(email: cleanEmail);
  }

  /// Sign out the current user session and terminate Firebase credentials.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- Validation Helpers ---

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}\$');
    return emailRegex.hasMatch(email.trim());
  }

  static String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    return null;
  }

  void _validateCredentials(String email, String password) {
    if (!isValidEmail(email)) {
      throw const FormatException('Invalid email format.');
    }
    final passError = validatePassword(password);
    if (passError != null) {
      throw FormatException(passError);
    }
  }

  /// Safe translation of Firebase Authentication errors into friendly messages.
  static String mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'invalid-email':
          return 'The email address is not formatted correctly.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 8 characters.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Access is temporarily paused for security. Try again in a few minutes.';
        case 'operation-not-allowed':
          return 'Email/Password sign-in is not enabled in Firebase project settings.';
        case 'network-request-failed':
          return 'Network connection failed. Please check your internet connection.';
        case 'requires-recent-login':
          return 'This sensitive operation requires you to sign in again.';
        default:
          return error.message ?? 'An unexpected authentication error occurred.';
      }
    } else if (error is FormatException) {
      return error.message;
    } else if (error is StateError) {
      return error.message;
    }
    return 'Authentication error: $error';
  }
}
