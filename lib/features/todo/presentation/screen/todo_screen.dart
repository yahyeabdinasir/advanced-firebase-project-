import 'package:advanced_firebase/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:advanced_firebase/features/todo/data/repository/todo_repository_imple.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // In Flutter and programming, final TodoRepositoryImpl repository means you are creating a read-only variable
  // named repository that holds an object of the TodoRepositoryImpl class.
  // The final keyword means you cannot change this variable to point to a new object after you set it.
  late final TodoRepositoryImple repository;
  @override
  void initState() {
    super.initState();
    final dataSource = TodoRemoteDatasource(http.Client());
    repository = TodoRepositoryImple(repository: dataSource);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(" Todo App")),

      body: FutureBuilder(
        future: repository.getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          ;
          if (snapshot.hasError) {
            return Center(child: Text("Error ${snapshot.error}"));
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
