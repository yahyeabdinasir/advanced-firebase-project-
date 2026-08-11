// Who gives me products?  the answer is the TodoRepository.  It is an abstract class that defines the methods for interacting with the data source of the Todo feature. 
// The implementation of this repository will be provided by a concrete class that will handle the actual data operations, such as fetching, adding, updating, and deleting todos.

//  so this repository is only about the contract of the methods that will be used to interact with the data source, and it does not contain any implementation details.

import 'package:advanced_firebase/features/todo/domain/entities/todo_entities.dart';

abstract class TodoRepository {
  // The application needs a way to get Todos.
  Future<List<TodoEntities>> getTodos();
  // Future<void> addTodo (String title) async {}
  // Future<void> updateTodo (TodoModel todo) async {}
  // Future<void> deleteTodo (int id) async {}
}

      //  DOMAIN
      //               │
      //     ┌─────────▼─────────┐
      //     │  TodoRepository   │
      //     │    (contract)     │
      //     └─────────▲─────────┘
      //               │
      //               │ implements
      //               │
      //             DATA
      //               │
      //     ┌─────────┴─────────┐
      //     │ TodoRepositoryImpl│
      //     └─────────┬─────────┘
      //               │
      //               │ calls
      //               ↓
      //     ┌───────────────────┐
      //     │ TodoRemoteDataSource│
      //     └─────────┬─────────┘
      //               │
      //               │ HTTP
      //               ↓
      //              API


        // PRESENTATION
        //            │
        //            │ depends on
        //            ↓
        //       ┌─────────────┐
        //       │   DOMAIN    │
        //       │             │
        //       │ Todo        │
        //       │ Repository  │
        //       └──────▲──────┘
        //              │
        //              │ implements
        //              │
        //       ┌──────┴──────┐
        //       │    DATA     │
        //       │             │
        //       │ Repository  │
        //       │ DataSource  │
        //       │ Model       │
        //       └──────┬──────┘
        //              │
        //              ↓
        //             API