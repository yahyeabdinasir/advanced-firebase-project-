import 'package:advanced_firebase/models/todo.dart';
import 'package:flutter_riverpod/legacy.dart';

// - [addListener], to manually listen to a [StateNotifier]
class TodoNotifier extends StateNotifier<List<Todo>>  {
  TodoNotifier() : super([]);

  void addTodo(String title) {
    // - [state], to internally read and update the value exposed.
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),

      title: title,
      completed: false,
    );

    state = [...state, todo];
  }



  void removeTodo(String id) {
    state = state.where((delelteItem) => delelteItem.id != id).toList();
  }


  void ToggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(
          completed : !todo.completed
        );
      } return todo;
    }).toList();
  }



  void updateTodo(String id , String NewTitle) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(
          title : NewTitle
        );
      }; return todo;
    }).toList();
  }

}
