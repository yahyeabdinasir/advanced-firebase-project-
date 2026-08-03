import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns the shared number list for Home + Second screen.
///
/// Why Notifier (not setState)?
/// - State lives outside any single widget
/// - Any screen can read/update it with `ref`
/// - Every listener rebuilds when `state` changes
class NumbersNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [1, 2, 3, 4, 5];

  void increment() {
    // Replace state with a new list (immutable update).
    // Riverpod notifies listeners only when you assign to `state`.
    state = [...state, state.last + 1];
  }
}

/// Global access point for the list.
/// Both screens watch/read this same provider — no passing lists via constructors.
final numbersProvider =
    NotifierProvider<NumbersNotifier, List<int>>(NumbersNotifier.new);
