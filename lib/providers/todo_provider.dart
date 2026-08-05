


import 'package:advanced_firebase/models/todo.dart';
import 'package:advanced_firebase/notifiers/todo_notifiers.dart';
import 'package:flutter_riverpod/legacy.dart';

final todoProvider = StateNotifierProvider<TodoNotifier , List<Todo>>((ref) {
  return TodoNotifier();
});