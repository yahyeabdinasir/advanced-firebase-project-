import 'package:advanced_firebase/features/todo/domain/entities/todo_entities.dart';
import 'package:advanced_firebase/features/todo/domain/usecase/get_todo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'todo_bloc_event.dart';
part 'todo_bloc_state.dart';

class TodoBlocBloc extends Bloc<TodoBlocEvent, TodoBlocState> {
  TodoBlocBloc(this._getTodos)
    : //   on<LoadTodosRequested>(...) means: when that event arrives, run this handler.
      // super(TodoBlocInitial()) is the first state, before any event.
      super(TodoBlocInitial()) {
    on<LoadTodoRequested>(_onLoadTodoRequested);
  }

  final GetTodos _getTodos;
  Future<void> _onLoadTodoRequested(
    LoadTodoRequested event,
    Emitter<TodoBlocState> emit,
  ) async {
    emit(TodoLoading());
    try {
      final todos = await _getTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }
}

// The Bloc receives events and emits states. It is the only presentation class allowed to call the use case.”
