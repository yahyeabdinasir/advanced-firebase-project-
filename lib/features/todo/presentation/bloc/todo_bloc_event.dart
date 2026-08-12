part of 'todo_bloc_bloc.dart';

@immutable
sealed class TodoBlocEvent {}
final class LoadTodoRequested extends TodoBlocEvent{}
