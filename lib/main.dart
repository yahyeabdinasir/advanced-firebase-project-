import 'package:advanced_firebase/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:advanced_firebase/features/todo/data/repository/todo_repository_imple.dart';
import 'package:advanced_firebase/features/todo/domain/usecase/get_todo.dart';
import 'package:advanced_firebase/features/todo/presentation/bloc/todo_bloc_bloc.dart';
import 'package:advanced_firebase/features/todo/presentation/screen/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

void main() {
  // Only main is allowed to build the low-level objects.
  final dataSource = TodoRemoteDatasource(http.Client());
  final repository = TodoRepositoryImple(remoteDatasource: dataSource);
  final getTodos = GetTodos(repository);

  runApp(TodoApp(getTodos: getTodos));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.getTodos});

  final GetTodos getTodos;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),
      home: BlocProvider(
        create: (_) => TodoBlocBloc(getTodos)
          ..add(
            LoadTodoRequested(),
          ), //  fires the first event as soon as the Bloc is created (user opened the app
        child: const TodoScreen(),
      ),
    );
  }
}
