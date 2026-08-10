import 'dart:convert';

import 'package:advanced_firebase/features/todo/data/models/todo.dart';
import 'package:http/http.dart' as http;

class TodoRemoteDatasource {
  final http.Client client;

  TodoRemoteDatasource(this.client);

  Future<List<TodoModel>> getTestingTodos() async {
    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/todos');
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        //     jsonList contains the API data, and .map() takes each JSON element and converts it into a TodoModel, then .toList() turns all those converted elements back into a list.

        // So:

        // jsonList
        //    ↓
        // each jsonElement
        //    ↓
        // TodoModel.fromJson(jsonElement)
        //    ↓
        // List<TodoModel>
        return jsonList
            .map((jsonElement) => TodoModel.fromJson(jsonElement))
            .toList();
      }
      throw Exception('Failed to fetch todos: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }
}

// Dependency Inversion Principle (DIP), the "D" in the SOLID software design rules. It means your main business rules should not break if a tool,
// database, or small helper function changes. Instead of linking parts directly, you connect them through a general rule or outline
