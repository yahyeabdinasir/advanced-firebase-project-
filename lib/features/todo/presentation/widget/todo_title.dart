// import 'package:flutter/material.dart';
// import '../../data/models/todo.dart';

// class TodoTile extends StatelessWidget {
//   final Todo todo;
//   final VoidCallback onDelete;
//   final VoidCallback onToggle;
//   final VoidCallback onEdit;

//   const TodoTile({
//     super.key,
//     required this.todo,
//     required this.onDelete,
//     required this.onToggle,
//     required this.onEdit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: Checkbox(
//           value: todo.completed,
//           onChanged: (_) => onToggle(),
//         ),
//         title: Text(
//           todo.title,
//           style: TextStyle(
//             decoration: todo.completed
//                 ? TextDecoration.lineThrough
//                 : null,
//           ),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: onEdit,
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: onDelete,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }