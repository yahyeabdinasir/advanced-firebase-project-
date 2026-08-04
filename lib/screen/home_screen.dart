import 'package:advanced_firebase/services/todo_title.dart';
import 'package:advanced_firebase/widget/lib/widgets/add_todo_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override

//   WidgetRef is a class provided by Riverpod.
// It contains methods like watch, read, and listen that allow you to interact with providers and manage state in your Flutter application.
  Widget build(BuildContext context, WidgetRef ref) {




    // ref it is the way to access the provider in Riverpod .
    // it allow you to read and watch the state of the provider
    // and also it's used to interact with the state of the provider and rebuild the widget when the state changes 

    //  so ref it comes when we need to interact or talk to the proivider and also to rebuild the widget when the state changes 
    final todos = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riverpod Todo"),
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text("No Todos"),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (_, index) {
                final todo = todos[index];

                return TodoTile(
                  todo: todo,
                  onDelete: () {
                    ref
                        .read(todoProvider.notifier)
                        .removeTodo(todo.id);
                  },
                  onToggle: () {
                    ref
                        .read(todoProvider.notifier)
                        .ToggleTodo(todo.id);
                  },
                  onEdit: () async {
                    final controller =
                        TextEditingController(
                      text: todo.title,
                    );

                    final result =
                        await showDialog<String>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Edit Todo"),
                        content: TextField(
                          controller: controller,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                controller.text,
                              );
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    );

                    if (result != null &&
                        result.trim().isNotEmpty) {
                      ref
                          .read(todoProvider.notifier)
                          .updateTodo(
                            todo.id,
                            result,
                          );
                    }
                  },
                );
              },
            ),
      floatingActionButton:
          FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final title =
              await showDialog<String>(
            context: context,
            builder: (_) =>
                const AddTodoDialog(),
          );

          if (title != null &&
              title.trim().isNotEmpty) {
            ref
                .read(todoProvider.notifier)
                .addTodo(title);
          }
        },
      ),
    );
  }
}