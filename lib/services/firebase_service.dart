import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // static final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  // );
  static bool _isInitialized = false;
  static UserModel? _currentUser;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Listen to auth state changes
      _auth.authStateChanges().listen(_onAuthStateChanged);
      
      // Check if user is already signed in
      final user = _auth.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
      }

      _isInitialized = true;
      debugPrint('FirebaseService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FirebaseService: $e');
    }
  }

  static void _onAuthStateChanged(User? user) {
    if (user != null) {
      _loadUserData(user.uid);
    } else {
      _currentUser = null;
    }
  }

  /// Sign in with Google
  static Future<UserModel?> signInWithGoogle() async {
    try {
      // Temporarily disabled due to API changes in google_sign_in 7.2.0
      debugPrint('Google Sign-In temporarily disabled due to API changes');
      return null;
      
      // TODO: Fix Google Sign-In API for version 7.2.0
      /*
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        await _loadUserData(user.uid);
        await _syncUserData();
        return _currentUser;
      }
      
      return null;
      */
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      // await _googleSignIn.signOut(); // Temporarily disabled
      _currentUser = null;
      
      // Save Firebase disabled state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('firebase_enabled', false);
      
      debugPrint('Signed out successfully');
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Load user data from Firestore
  static Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = UserModel.fromMap({
          'uid': uid,
          'email': _auth.currentUser?.email,
          'displayName': _auth.currentUser?.displayName,
          'photoURL': _auth.currentUser?.photoURL,
          ...data,
          'isFirebaseEnabled': true,
        });
      } else {
        // Create new user document
        _currentUser = UserModel(
          uid: uid,
          email: _auth.currentUser?.email,
          displayName: _auth.currentUser?.displayName,
          photoURL: _auth.currentUser?.photoURL,
          totalSessions: 0,
          totalMinutes: 0,
          currentStreak: 0,
          bestStreak: 0,
          isFirebaseEnabled: true,
        );
        await _syncUserData();
      }
      
      // Save Firebase enabled state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('firebase_enabled', true);
      
      debugPrint('User data loaded: ${_currentUser?.displayName}');
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  /// Sync local user data to Firestore
  static Future<void> _syncUserData() async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).set(
        _currentUser!.toMap(),
        SetOptions(merge: true),
      );
      debugPrint('User data synced to Firestore');
    } catch (e) {
      debugPrint('Error syncing user data: $e');
    }
  }

  /// Update user stats in Firestore
  static Future<void> updateUserStats({
    required int totalSessions,
    required int totalMinutes,
    required int currentStreak,
    required int bestStreak,
  }) async {
    if (_currentUser == null) return;

    try {
      _currentUser = _currentUser!.copyWith(
        totalSessions: totalSessions,
        totalMinutes: totalMinutes,
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        lastSessionDate: DateTime.now(),
      );

      await _syncUserData();
      debugPrint('User stats updated in Firestore');
    } catch (e) {
      debugPrint('Error updating user stats: $e');
    }
  }

  /// Get leaderboard data
  static Future<List<UserModel>> getLeaderboard({int limit = 10}) async {
    try {
      final query = await _firestore
          .collection('users')
          .orderBy('currentStreak', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap({
          'uid': doc.id,
          ...data,
          'isFirebaseEnabled': true,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return [];
    }
  }

  /// Check if Firebase is enabled
  static Future<bool> isFirebaseEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firebase_enabled') ?? false;
  }

  /// Enable/disable Firebase
  static Future<void> setFirebaseEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firebase_enabled', enabled);
    
    if (!enabled) {
      await signOut();
    }
  }

  /// Get current user
  static UserModel? get currentUser => _currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => _auth.currentUser != null;
}
