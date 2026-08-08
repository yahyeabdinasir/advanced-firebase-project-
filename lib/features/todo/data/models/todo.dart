import 'package:advanced_firebase/features/todo/domain/entities/todo_entities.dart';

class TodoModel  extends TodoEntities { 

   TodoModel({
       
    required super.id , 
    required super.title , 
    required super.completed 
  });



  // our api gives us a JSON response, so we need to convert that JSON into our Dart object. The fromJson factory constructor takes a Map<String, dynamic> as input and returns an instance of TodoModel.
  // It extracts the values from the JSON map and assigns them to the corresponding properties of the TodoModel class. This allows us to easily create TodoModel objects from the JSON data we receive from the API.

// converts that JSON into our Dart object.

  factory TodoModel.fromJson(Map<String , dynamic> json ) {
    return TodoModel(
      id : json['id'] as int ,
      title : json['title'] as String ,
       completed : json['completed'] as bool
    );
  }



  Map<String , dynamic> toJson() {
    return {
      'id' : id ,
      'title' : title ,
      'completed' : completed
    };
  }
}