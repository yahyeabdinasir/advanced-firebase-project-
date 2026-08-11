import 'package:advanced_firebase/features/todo/domain/usecase/get_todo.dart';
import 'package:advanced_firebase/features/todo/presentation/screen/todo_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.getTodos});

  final GetTodos getTodos;

  @override
  Widget build(BuildContext context) {
    return TodoScreen(getTodos: getTodos);
  }
}
