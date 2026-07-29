import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(AppConfig.UserCollection);

  Future<void> createUser(UserModel user) {
    return _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return UserModel.fromMap(snapshot.data()!);
  }
}
