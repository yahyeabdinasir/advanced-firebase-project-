import 'package:advanced_firebase/features/todo/presentation/bloc/todo_bloc_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo App')),
      body: BlocBuilder<TodoBlocBloc, TodoBlocState>(
        builder: (context, state) {
          if (state is TodoBlocInitial || state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TodoError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state is TodoLoaded) {
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final todo = state.todos[index];
                return ListTile(
                  leading: Checkbox(value: todo.completed, onChanged: null),
                  title: Text(todo.title),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
