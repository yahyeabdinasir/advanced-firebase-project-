import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';

/// Saves and loads user profiles in Firestore.
///
/// Auth = "who is logged in?"
/// Firestore = "extra data about that person" (name, etc.)
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Collection name from AppConfig (e.g. "users")
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(AppConfig.UserCollection);

  /// Create a profile document right after signup.
  /// Document id = Auth uid so each account has exactly one profile.
  Future<void> createUser(UserModel user) {
    return _users.doc(user.uid).set(user.toMap());
  }

  /// Read one profile by Auth uid. Returns null if the doc does not exist.
  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return UserModel.fromMap(snapshot.data()!);
  }
}
