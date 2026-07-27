/// Our app's user profile stored in Firestore (not Auth).
///
/// Firebase Auth only keeps: uid, email, password (hashed), etc.
/// Extra fields (name, createdAt, …) live in Firestore under users/{uid}.
class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  /// Turn this object into a Map so Firestore can save it.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      // Store as ISO string — easy to read in Firebase Console
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Build a UserModel from a Firestore document.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
