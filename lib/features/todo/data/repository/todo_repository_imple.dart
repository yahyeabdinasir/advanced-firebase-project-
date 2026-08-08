import 'package:advanced_firebase/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:advanced_firebase/features/todo/data/models/todo.dart';
import 'package:advanced_firebase/features/todo/domain/repository/todo_repository.dart';

class TodoRepositoryImple  implements TodoRepository{ 

final TodoRemoteDatasource remoteDatasource ; 
TodoRepositoryImple({required this.remoteDatasource});

 @override
Future<List<TodoModel>> getTodos() async {  
  return remoteDatasource.getTodos();
  
}
}