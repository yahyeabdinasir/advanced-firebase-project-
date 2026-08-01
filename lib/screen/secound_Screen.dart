import 'package:flutter/material.dart';

class SecoundScreen extends StatefulWidget {
    final List<int> numbers;

  const SecoundScreen({super.key, required this.numbers});

  @override
  State<SecoundScreen> createState() => _SecoundScreenState();
}

class _SecoundScreenState extends State<SecoundScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).primaryColor),
      body: Column(
        children: [
          Text(widget.numbers.last.toString()),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return const Text('1');
              },
            ),
          ),
        
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.pop(context);
        },
        child: Icon(Icons.add, color: Theme.of(context).primaryColorLight),
      ),
    );
  }
}
