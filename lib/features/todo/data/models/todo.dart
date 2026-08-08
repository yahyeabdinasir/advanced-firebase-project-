class Todo {
  Todo({required this.id, required this.title, required this.completed});

  final String id;
  final String title;
  final bool completed;

  // Instead of changing an object directly:   todo.completed = true; // ❌
  // We create a new object:

  // final updated = todo.copyWith(completed: true);

  // This keeps our state immutable, which is the recommended pattern in Riverpod
  Todo copyWith({String? id, String? title, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'] as String,
    title: json['title'] as String,
    completed: json['completed'] as bool,
  );

  Map<String, dynamic> tojson() => {
    'id': id,
    'title': title,
    'completed': completed,
  };
}
