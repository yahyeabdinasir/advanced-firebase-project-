import 'package:advanced_firebase/features/todo/domain/entities/todo_entities.dart';
import 'package:advanced_firebase/features/todo/domain/repository/todo_repository.dart';

class GetTodos {
  final TodoRepository repository;

  GetTodos(this.repository);

  Future<List<TodoEntities>> call() async {
    return repository.getTodos();

  } 

}

// The easiest way to remember it

// Repository says WHAT we need.
// Data source says HOW we get it.
// Repository implementation connects the two

