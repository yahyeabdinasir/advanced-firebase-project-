import 'package:advanced_firebase/features/todo/data/datasources/todo_remote_datasource.dart';
import 'package:advanced_firebase/features/todo/domain/entities/todo_entities.dart';
import 'package:advanced_firebase/features/todo/domain/repository/todo_repository.dart';

// When someone asks the repository for todos, get them from the datasource.
// this is the implementation of the contract  it's says when someone asks the repository for todos  i will get them from my datasource 
class TodoRepositoryImple implements TodoRepository {
  TodoRepositoryImple({required this.remoteDatasource});

  final TodoRemoteDatasource remoteDatasource;

  @override
  Future<List<TodoEntities>> getTodos() async {
    // Go to the datasource. Call the API. Wait until the answer comes back
//     HTTP GET to JSONPlaceholder
// JSON text comes back
// Each JSON item becomes a TodoModel (fromJson)
// You get a List<TodoModel>


// This method is the translator between the internet and your app.

// The screen / use case only says: “give me todos.”
// They do not know about HTTP or JSON. This class does.

// Line by line

// @override
// “I am filling in the promise from TodoRepository. The contract said getTodos() exists. Here is the real work.”

// Future<List<TodoEntities>>
// “I will not give you the list instantly. I will give you a later result: a list of domain todos.”

// async
// Lets you use await and wait without freezing the UI
    final todos = await remoteDatasource.getTestingTodos();
    return List<TodoEntities>.from(todos);
  }
}


// this is the overall follow 
// SCREEN
//    │
//    │ getTodos()
//    ↓
// REPOSITORY
//    │
//    │ getTodos()
//    ↓
// DATA SOURCE
//    │
//    │ HTTP GET
//    ↓
// API


// TodoScreen
    // ↓
// TodoRepository       ← abstraction
//     ↑
// TodoRepositoryImpl   ← implementation
//     ↓
// TodoRemoteDataSource