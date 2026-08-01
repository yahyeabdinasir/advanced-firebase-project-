import 'package:advanced_firebase/screen/secound_Screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<int> numbers = [1, 2, 3, 4, 5];

  void IncrementNumber() {
    setState(() {
      numbers.add(numbers.last + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).primaryColor),
      body: Column(
        children: [
          Text(numbers.last.toString()),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Text(numbers[index].toString());
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecoundScreen(numbers: numbers),
                ),
              );
            },
            child: Text('Go to Second Screen'),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          IncrementNumber();
        },
        child: Icon(Icons.add, color: Theme.of(context).primaryColorLight),
      ),
    );
  }
}
