import 'package:advanced_firebase/features/todo/domain/entities/todo_entities.dart';
import 'package:advanced_firebase/features/todo/domain/usecase/get_todo.dart';
import 'package:flutter/material.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key, required this.getTodos});

  final GetTodos getTodos;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final Future<List<TodoEntities>> _todos;

  @override
  void initState() {
    super.initState();
    _todos = widget.getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo App')),
      body: FutureBuilder(
        future: _todos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final todoData = data[index];
              return ListTile(
                leading: Checkbox(value: todoData.completed, onChanged: null),
                title: Text(todoData.title),
              );
            },
          );
        },
      ),
    );
  }
}
