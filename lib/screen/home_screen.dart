import 'package:advanced_firebase/providers/numbers_provider.dart';
import 'package:advanced_firebase/screen/secound_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ConsumerWidget = StatelessWidget + access to `ref`.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch → rebuild this widget when numbersProvider changes
    final numbers = ref.watch(numbersProvider);

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).primaryColor),
      body: Column(
        children: [
          Text(numbers.last.toString()),
          Expanded(
            child: ListView.builder(
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                return Text((numbers[index] * 10).toString());
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // No list passed — Second screen reads the same provider.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SecoundScreen(),
                ),
              );
            },
            child: const Text('Go to Second Screen'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // read → call a method without creating an extra rebuild subscription
          ref.read(numbersProvider.notifier).increment();
        },
        child: Icon(Icons.add, color: Theme.of(context).primaryColorLight),
      ),
    );
  }
}
