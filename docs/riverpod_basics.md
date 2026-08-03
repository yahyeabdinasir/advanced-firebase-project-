# Riverpod Basics (Minimum Learning Path)

This doc walks through **our two-screen number list** — what broke with `setState`, and how Riverpod fixes it with the smallest useful setup.

---

## 1. The old flow (setState only)

```
HomeScreen (owns List<int> numbers)
   │
   │  Navigator.push(SecoundScreen(numbers: numbers))  ← same list reference
   ▼
SecoundScreen (mutates widget.numbers + setState)
```

### What looked fine

- Home FAB: `setState` → add number → Home UI updates.
- Second FAB: `setState` → add number → Second UI updates.
- The list object was shared by reference, so the data *was* updated in memory.

### Side effects of no real state management

| Problem | What happened in our app |
|--------|---------------------------|
| **Stale UI on pop** | Second mutated the list, but Home never rebuilt on return. Home looked wrong until you tapped + again. |
| **Tight coupling** | Second needed `numbers` in its constructor. More screens = more parameter drilling. |
| **Who owns state?** | Home “owned” the list, but Second mutated `widget.numbers` — ownership became unclear. |
| **Rebuild scope** | `setState` rebuilds that widget only. Siblings/parents do not know anything changed. |
| **Hard to test / reuse** | Logic lived inside widgets. You cannot easily share the list with a third screen or a service. |
| **Bugs hide as “works sometimes”** | Shared mutable list + local `setState` = data correct, UI inconsistent. |

**Core lesson:** `setState` is fine for *local* UI (open/close a dialog). It is a poor fit when **two or more screens share the same data**.

---

## 2. Riverpod mental model (only 4 ideas)

Learn these four first. Ignore the rest of Riverpod until these feel natural.

1. **`ProviderScope`** — wrap the app once in `main.dart`. Without it, providers do not work.
2. **Provider** — a named box that holds state (or creates a value). Ours: `numbersProvider`.
3. **`ref.watch(provider)`** — “give me the value **and** rebuild me when it changes.” Use in `build`.
4. **`ref.read(provider)`** — “give me the value **once** (or call a method).” Use in button callbacks.

```
ProviderScope
   └── MyApp
         └── HomeScreen  ──watch──► numbersProvider ◄──watch── SecoundScreen
                                         ▲
                                         │ read().increment()
                                      (FAB on either screen)
```

Both screens talk to the **same** provider. No list is passed between routes.

---

## 3. What we added in this project

| File | Role |
|------|------|
| `lib/providers/numbers_provider.dart` | `NumbersNotifier` + `numbersProvider` — the single source of truth |
| `lib/main.dart` | `ProviderScope` wraps `MyApp` |
| `lib/screen/home_screen.dart` | `ConsumerWidget` — watches + increments |
| `lib/screen/secound_Screen.dart` | Same — no constructor list anymore |

### Notifier pattern (minimum “real” Riverpod)

```dart
class NumbersNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [1, 2, 3, 4, 5];  // initial state

  void increment() {
    state = [...state, state.last + 1];   // assign new state → notify listeners
  }
}

final numbersProvider =
    NotifierProvider<NumbersNotifier, List<int>>(NumbersNotifier.new);
```

- `build()` → initial value when the provider is first used.
- Assigning `state = ...` → Riverpod notifies every widget that `watch`ed this provider.
- Use a **new list** (`[...state, ...]`) so the change is visible; mutating in place without reassigning often fails to notify.

### In the UI

```dart
final numbers = ref.watch(numbersProvider);           // rebuild on change
ref.read(numbersProvider.notifier).increment();      // call method on press
```

---

## 4. Step-by-step: how a tap flows

1. User taps FAB on Second screen.
2. `ref.read(numbersProvider.notifier).increment()` runs.
3. Notifier sets `state = [...state, state.last + 1]`.
4. Riverpod notifies **all** watchers of `numbersProvider`.
5. Home **and** Second both rebuild with the new list (Home may be under the route stack — it still stays in sync).
6. User pops back → Home already shows the correct last number. **No stale UI.**

---

## 5. watch vs read (memorize this)

| Use | When |
|-----|------|
| `ref.watch` | Inside `build` — you want the widget to rebuild |
| `ref.read` | Inside `onPressed` / one-shot actions — do **not** subscribe |

Wrong: `ref.watch` inside `onPressed` (unnecessary / confusing).  
Wrong: `ref.read` in `build` for values you display (UI will not update).

---

## 6. Minimum learning roadmap

Stay on each step until it feels boring, then move on.

| Step | Learn | Practice in this app |
|------|--------|----------------------|
| **A** | `ProviderScope` + `ConsumerWidget` | Already done |
| **B** | `ref.watch` vs `ref.read` | Change last number UI; add from both screens |
| **C** | One `NotifierProvider` shared by 2 screens | Current `numbersProvider` |
| **D** | Derived / read-only provider | Add `final lastNumberProvider = Provider((ref) => ref.watch(numbersProvider).last);` |
| **E** | Async later | `FutureProvider` / `AsyncNotifier` for Firebase — **not yet** |

Do **not** start with code generation, `riverpod_generator`, or complex dependency graphs. Master A–C first.

---

## 7. Quick checklist — “did I understand Riverpod?”

- [ ] I can explain why Home looked stale after popping from Second with `setState`.
- [ ] I know why we need `ProviderScope`.
- [ ] I use `watch` in `build` and `read` in callbacks.
- [ ] Both screens update without passing `List<int>` in constructors.
- [ ] I assign a new `state` in the Notifier instead of only mutating a list in place.

---

## 8. Try it

1. Run the app.
2. On Home, tap `+` a few times.
3. Open Second screen — list should match.
4. Tap `+` on Second.
5. Pop back to Home — last number and list should already be updated.

That last step is the proof that shared state management fixed the side effect.
