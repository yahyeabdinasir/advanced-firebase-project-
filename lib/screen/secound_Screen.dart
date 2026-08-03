import 'package:advanced_firebase/providers/numbers_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Same provider as HomeScreen — shared state, no constructor list.
class SecoundScreen extends ConsumerWidget {
  const SecoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(numbersProvider.notifier).increment();
        },
        child: Icon(Icons.add, color: Theme.of(context).primaryColorLight),
      ),
    );
  }
}
