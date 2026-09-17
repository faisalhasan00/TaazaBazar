import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../domain/user_profile.dart';

/// Repository for handling User Profile stored at users/{uid}/profile in Cloud Firestore
class ProfileRepository {
  static final ProfileRepository _instance = ProfileRepository._internal();
  factory ProfileRepository() => _instance;
  ProfileRepository._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Active Firebase User ID
  String? get _currentUserId => FirebaseAuthService().currentUserId;

  /// Cached in-memory profile
  UserProfile? _cachedProfile;

  /// Current cached profile
  UserProfile? get cachedProfile => _cachedProfile;

  /// Helper reference to users/{uid}/profile document
  DocumentReference<Map<String, dynamic>>? _getProfileDocRef(FirebaseFirestore db, String uid) {
    return db.collection('users').doc(uid).collection('profile').doc('profile');
  }

  /// Real-time stream of the user profile from users/{uid}/profile
  Stream<UserProfile?> getProfileStream({String? userId}) {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null || uid.isEmpty) {
      return Stream.value(_cachedProfile ?? (uid != null ? UserProfile(uid: uid) : null));
    }

    try {
      final docRef = _getProfileDocRef(db, uid);
      if (docRef == null) {
        return Stream.value(_cachedProfile ?? UserProfile(uid: uid));
      }

      return docRef.snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          final defaultProfile = UserProfile(uid: uid);
          _cachedProfile = defaultProfile;
          return defaultProfile;
        }
        final profile = UserProfile.fromMap(snapshot.data()!, snapshot.id);
        _cachedProfile = profile;
        return profile;
      }).handleError((e) {
        debugPrint('ProfileRepository: Firestore stream error: $e');
        return _cachedProfile ?? UserProfile(uid: uid);
      });
    } catch (e) {
      debugPrint('ProfileRepository: getProfileStream catch: $e');
      return Stream.value(_cachedProfile ?? UserProfile(uid: uid));
    }
  }

  /// Fetch user profile once from users/{uid}/profile
  Future<UserProfile?> getProfile({String? userId}) async {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null || uid.isEmpty) {
      return _cachedProfile ?? (uid != null ? UserProfile(uid: uid) : null);
    }

    try {
      final docRef = _getProfileDocRef(db, uid);
      if (docRef == null) return _cachedProfile ?? UserProfile(uid: uid);

      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        final profile = UserProfile.fromMap(doc.data()!, doc.id);
        _cachedProfile = profile;
        return profile;
      }
      return null;
    } catch (e) {
      debugPrint('ProfileRepository: getProfile error: $e');
      return _cachedProfile ?? UserProfile(uid: uid);
    }
  }

  /// Automatically create user profile at users/{uid}/profile if missing
  Future<UserProfile?> createProfileIfMissing({String? userId}) async {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null || uid.isEmpty) {
      debugPrint('ProfileRepository: Warning - no active Firebase user to check/create profile.');
      return null;
    }

    try {
      final targetDocRef = _getProfileDocRef(db, uid)!;
      final targetDoc = await targetDocRef.get();

      // 1. If target users/{uid}/profile already exists, load and return it
      if (targetDoc.exists && targetDoc.data() != null) {
        debugPrint('ProfileRepository: Existing profile found at users/$uid/profile');
        final profile = UserProfile.fromMap(targetDoc.data()!, targetDoc.id);
        _cachedProfile = profile;
        return profile;
      }

      // 2. Safe Migration: Check if legacy profile exists at users/{uid}
      final legacyDocRef = db.collection('users').doc(uid);
      final legacyDoc = await legacyDocRef.get();
      if (legacyDoc.exists && legacyDoc.data() != null) {
        final legacyData = legacyDoc.data()!;
        if (legacyData.containsKey('name') || legacyData.containsKey('memberStatus')) {
          debugPrint('ProfileRepository: Migrating legacy profile from users/$uid to users/$uid/profile');
          final migratedProfile = UserProfile.fromMap(legacyData, uid);
          await targetDocRef.set(migratedProfile.toMap(), SetOptions(merge: true));
          _cachedProfile = migratedProfile;

          // Safely delete legacy document only if it contains purely profile fields
          final isPureProfile = !legacyData.containsKey('addresses') &&
              !legacyData.containsKey('cart') &&
              !legacyData.containsKey('orders');
          if (isPureProfile) {
            await legacyDocRef.delete();
            debugPrint('ProfileRepository: Safely cleaned up legacy users/$uid document');
          }
          return migratedProfile;
        }
      }

      // 3. Create fresh default generic profile at users/{uid}/profile
      debugPrint('ProfileRepository: Creating new Firestore profile at users/$uid/profile');
      final newProfile = UserProfile(
        uid: uid,
        name: 'Guest User',
        phone: '',
        email: '',
        photoUrl: '',
        isPassMember: false,
        memberStatus: 'TaazaBazar Member',
      );

      await targetDocRef.set(newProfile.toMap(), SetOptions(merge: true));
      _cachedProfile = newProfile;
      debugPrint('ProfileRepository: Successfully created profile at users/$uid/profile');
      return newProfile;
    } catch (e) {
      debugPrint('ProfileRepository: createProfileIfMissing notice: $e');
      return _cachedProfile ?? UserProfile(uid: uid);
    }
  }

  /// Update user profile at users/{uid}/profile
  /// Updates ONLY editable fields: name, phone, email, updatedAt
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String email,
    String? userId,
  }) async {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (uid == null || uid.isEmpty) {
      debugPrint('ProfileRepository: Cannot update profile - empty UID');
      throw Exception('User is not authenticated');
    }

    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    final trimmedEmail = email.trim();

    // Update in-memory cached profile
    if (_cachedProfile != null) {
      _cachedProfile = _cachedProfile!.copyWith(
        name: trimmedName,
        phone: trimmedPhone,
        email: trimmedEmail,
        updatedAt: DateTime.now(),
      );
    } else {
      _cachedProfile = UserProfile(
        uid: uid,
        name: trimmedName,
        phone: trimmedPhone,
        email: trimmedEmail,
        updatedAt: DateTime.now(),
      );
    }

    if (db != null) {
      try {
        final targetDocRef = _getProfileDocRef(db, uid)!;
        final profileData = {
          'name': trimmedName,
          'phone': trimmedPhone,
          'email': trimmedEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await targetDocRef.set(profileData, SetOptions(merge: true));

        // Also merge to top-level users/{uid} document for Admin Dashboard sync
        await db.collection('users').doc(uid).set({
          'name': trimmedName,
          'phone': trimmedPhone,
          'email': trimmedEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('ProfileRepository: Updated profile at users/$uid/profile and users/$uid');
      } catch (e) {
        debugPrint('ProfileRepository: updateProfile error: $e');
        rethrow;
      }
    }
  }
}
