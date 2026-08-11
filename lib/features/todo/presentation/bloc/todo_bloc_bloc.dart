import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'todo_bloc_event.dart';
part 'todo_bloc_state.dart';

class TodoBlocBloc extends Bloc<TodoBlocEvent, TodoBlocState> {
  TodoBlocBloc() : super(TodoBlocInitial()) {
    on<TodoBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
