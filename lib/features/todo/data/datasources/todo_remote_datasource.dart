import 'dart:convert';

import 'package:advanced_firebase/features/todo/data/models/todo.dart';
import 'package:http/http.dart' as http;

class TodoRemoteDatasource { 

final http.Client client;

TodoRemoteDatasource(this.client);


Future<List<TodoModel>> getTodos() async {
  try {

  final url = Uri.parse('https://jsonplaceholder.typicode.com/todos');
  final response = await client.get(url);
  if (response.statusCode == 200) {
    final List<dynamic> jsonList  = jsonDecode(response.body);
    return jsonList.map((jsonElement) => TodoModel.fromJson(jsonElement)).toList();
  }
   throw Exception('Failed to fetch todos: ${response.statusCode}');
  }
  catch (e) {
    throw Exception('Failed to fetch todos: $e');
  }

}


  
  
   }