import 'package:advanced_firebase/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:advanced_firebase/features/todo/data/models/todo.dart';
import 'package:advanced_firebase/features/todo/domain/repository/todo_repository.dart';



// this is the implementation of the contract  it's says when someone asks the repository for todos  i will get them from my datasource 
class TodoRepositoryImple  implements TodoRepository{
TodoRepositoryImple({
  required this.repository
});

  final TodoRemoteDatasource repository ; 

  Future<List<TodoModel>> getTodos() async {
    return repository.getTestingTodos();
  }
  
}