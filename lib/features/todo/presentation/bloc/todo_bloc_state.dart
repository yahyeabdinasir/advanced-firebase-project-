part of 'todo_bloc_bloc.dart';

@immutable
sealed class TodoBlocState {}

final class TodoBlocInitial extends TodoBlocState {}

final class TodoLoading extends TodoBlocState {}

final class TodoLoaded extends TodoBlocState {
  TodoLoaded(this.todos);

  final List<TodoEntities> todos;
}

final class TodoError extends TodoBlocState {
  TodoError(this.errorMessage);
  final String errorMessage;
}
