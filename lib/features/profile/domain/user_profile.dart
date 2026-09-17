import 'package:cloud_firestore/cloud_firestore.dart';

/// User Profile Model representing authenticated user details in Cloud Firestore
class UserProfile {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String photoUrl;
  final bool isPassMember;
  final String memberStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    this.name = 'Guest User',
    this.phone = '',
    this.email = '',
    this.photoUrl = '',
    this.isPassMember = false,
    this.memberStatus = 'TaazaBazar Member',
    this.createdAt,
    this.updatedAt,
  });

  /// Dynamically compute avatar initials from name (e.g., "Guest User" -> "GU")
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'GU';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'isPassMember': isPassMember,
      'memberStatus': memberStatus,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserProfile(
      uid: map['uid']?.toString() ?? docId ?? '',
      name: map['name']?.toString() ?? 'Guest User',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      isPassMember: map['isPassMember'] as bool? ?? false,
      memberStatus: (map['memberStatus'] == null || map['memberStatus'] == 'Freshly Member')
          ? 'TaazaBazar Member'
          : map['memberStatus'].toString(),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    bool? isPassMember,
    String? memberStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isPassMember: isPassMember ?? this.isPassMember,
      memberStatus: memberStatus ?? this.memberStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
