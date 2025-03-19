import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

/// Model untuk data pengguna aplikasi
class UserModel {
  /// Unique identifier pengguna (dari Firebase Auth)
  final String uid;

  /// Email pengguna
  final String email;

  /// Nama tampilan pengguna
  final String? displayName;

  /// URL foto profil pengguna
  final String? photoURL;

  /// Status verifikasi email
  final bool emailVerified;

  /// Jenis kelamin pengguna
  final String? gender;

  /// Tanggal lahir pengguna
  final DateTime? birthDate;

  /// Waktu pembuatan akun
  final DateTime createdAt;

  /// Waktu login terakhir
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.emailVerified,
    this.gender,
    this.birthDate,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Membuat UserModel dari Firebase Auth User
  factory UserModel.fromFirebaseUser(
    auth.User firebaseUser, {
    String? gender,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      gender: gender,
      birthDate: birthDate,
      createdAt: createdAt ?? DateTime.now(),
      lastLoginAt: lastLoginAt ?? DateTime.now(),
    );
  }

  /// Membuat UserModel dari Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document data was null');
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      gender: data['gender'] as String?,
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Konversi UserModel ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'gender': gender,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  /// Membuat salinan UserModel dengan nilai yang diperbarui
  UserModel copyWith({
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    String? gender,
    DateTime? birthDate,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: this.uid,
      email: this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, emailVerified: $emailVerified)';
  }
}
