# State Management in Flutter

This document explains state management from the basics, through Provider, then Riverpod, and finally how it works in our Todo app.

It also covers the full learning path: Provider fundamentals, Riverpod basics, StateNotifier and AsyncNotifier, FutureProvider and StreamProvider, GoRouter navigation, and best practices.


## 1. What is state management?

State management is how an app stores and keeps the current data of its UI so that data stays correct as the user navigates and interacts.

A simple example is a counter. When you press a button, a number goes up. That number is state. In a bigger app, cart items in an e-commerce app are also state. When you leave a product page and open the cart, those items should still be there. They should not reset just because you changed screens.

Conceptually, state management keeps important data “in memory” and keeps different parts of the app synchronized with that same data.

Key takeaway: state management gives a smoother experience by preserving app data as users move around and interact.


## 2. A simple Flutter app without a state package

Imagine a basic app with two screens.

On the home screen you have:
- text showing a number at the top
- a list of numbers under it
- a floating action button that increments the last number and adds it to the list

At first this can be done with a StatefulWidget and setState only. No Provider, no Riverpod.

What works:
- Incrementing on the home screen updates the home UI correctly.
- You can pass the list to a second screen through the constructor and show it there (for example as a horizontal list).

What breaks:
- When the second screen changes the list and you go back, the first screen often does not look updated. The data may already be changed in memory, but Home did not rebuild, so the UI looks stale until you tap again.

The problem is that passing raw data through constructors does not create a shared, reactive source of truth. Screens become disconnected.

Typical implementation in this phase:
- A StatefulWidget owns a List of integers.
- Increment logic lives inside setState.
- Navigation passes the list as a constructor parameter.
- The second screen displays that list.
- On back navigation, state sync between screens is broken or incomplete.


### Side effects of setState-only sharing

In the numbers example, Home owned List of ints and passed the same list reference to Second. Second mutated that list and called setState on itself.

That caused several problems:

Stale UI. Second updated the data, but Home did not rebuild when you popped back. The list was correct in memory, but Home looked wrong until you tapped +.

Constructor coupling. Every new screen needed the numbers list passed in.

Unclear ownership. Home “owned” the list, but Second mutated widget.numbers.

Local rebuilds only. setState never notifies other screens.

setState is fine for local UI, like opening a dialog. It fails when two screens need to share one piece of data.


## 3. Introduction to Provider

Provider is a Flutter package for reactive state management based on ChangeNotifier.

What Provider does:
- Makes app-wide data available to many widgets without passing it by hand.
- Lets widgets listen to changes and rebuild automatically.
- Gives you one source of truth used consistently across screens.

How to set it up:

1. Add the provider package in pubspec.yaml.

2. Create a Dart file such as list_provider.dart with a class like NumbersListProvider that extends ChangeNotifier. Inside it, keep a list of integers and an add() method that increments the last item, appends it, and calls notifyListeners().

3. Wrap the app root with MultiProvider and register the provider:

MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => NumbersListProvider()),
  ],
  child: MyApp(),
);

4. In screens, use Consumer of NumbersListProvider to read the shared list and call methods. When state changes, those Consumers rebuild.

Benefits:
- No need to pass state through constructors.
- Both screens use the same provider instance.
- An update on one screen shows up on the other.
- State logic lives in a dedicated class.
- Easy to scale by adding more providers.


### How Provider behaves in detail

NumbersListProvider holds the data and the logic. Calling add() changes the list and calls notifyListeners(), which tells listening widgets to rebuild.

Both screens wrap parts of their UI with Consumer so they listen to the same provider. Floating action buttons on both screens call the provider’s add() method. The text and the list both read from the provider.

notifyListeners() is essential. Without it, the data may change but the UI will not update. With it, Consumers rebuild and the UI stays in sync.

A useful analogy is a shopping cart. Adding a product updates shared cart state. Opening the cart page shows the same items. Provider keeps that data and UI consistent.


### Provider best practices

Wrap MaterialApp with MultiProvider even if you only have one provider, so adding more later is easy.

Use Consumer only around the parts that need to rebuild, not the whole screen if you can avoid it.

Always call notifyListeners() after you change state inside provider methods.

Avoid passing shared state manually between widgets. That is how data gets out of sync.

Provider with ChangeNotifier and Consumer covers most common Flutter apps. For more advanced patterns, people often move to BLoC or Riverpod.


### Provider workflow in short

1. Create a class that extends ChangeNotifier.
2. Define state variables and methods that change them.
3. Call notifyListeners() inside those methods.
4. Register the provider at the app root with MultiProvider.
5. Read and update state in the UI with Consumer.
6. Call provider methods from widgets so every listener stays updated.


### Provider fundamentals: folder organization

When you grow past one file, keep Provider code easy to find. A simple layout looks like this:

lib/
  main.dart
  models/
  providers/
  screens/
  widgets/

main.dart creates MultiProvider and starts the app.

models/ holds plain data classes such as Product or CartItem.

providers/ holds ChangeNotifier classes and nothing about UI layout.

screens/ holds pages that use Consumer or context.watch.

widgets/ holds reusable UI pieces that may also listen to providers.

Sample app idea for Provider fundamentals: a small cart or numbers list with two screens sharing one ChangeNotifier. Home adds items. Cart screen shows the same list. No constructors pass the list around.


## 4. Riverpod state management

Riverpod is a modern state management solution for Flutter. It is flexible, performs well, and scales from small apps to large ones.

Compared with setState across screens, Riverpod gives you a single source of truth that any screen can watch.

Compared with the classic Provider package, Riverpod is safer about where you read state, works without depending as much on the widget tree, and rebuilds only widgets that depend on the changed state.


### ProviderScope

ProviderScope is the root container for all Riverpod providers. Think of it as a warehouse that stores every provider in your application.

You wrap the whole app once:

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

Without ProviderScope, providers do not work. Every Riverpod app starts here.


### ConsumerWidget and WidgetRef

ConsumerWidget is the usual way to build a screen that talks to Riverpod.

Instead of a normal StatelessWidget, you write:

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // use ref here
  }
}

WidgetRef (often just called ref) is the object Riverpod gives you. It contains the methods you need to interact with providers: watch, read, and listen.

You need WidgetRef in build whenever the widget must talk to a provider or rebuild when that provider changes.


### ref.watch

ref.watch(provider) means: give me the current value, and rebuild this widget when that value changes.

Use watch inside build when you display state on screen.

Example:

final todos = ref.watch(todoProvider);

When todoProvider changes, this ConsumerWidget rebuilds and shows the new list.


### ref.read

ref.read(provider) means: give me access once. It does not subscribe the widget for rebuilds.

Use read in button callbacks and one-shot actions, especially to call notifier methods:

onPressed: () {
  ref.read(todoProvider.notifier).addTodo(title);
}

Do not use read in build for values you want to keep updating. The UI will not refresh.


### ref.listen

ref.listen(provider, (previous, next) { ... }) is for side effects, not for building UI.

Use it when you want to show a SnackBar, navigate, or log something after state changes. The widget does not rebuild only because of listen. Rebuilds still come from watch.


### watch versus read

Use watch inside build when the UI should update when state changes.

Use read inside onPressed or similar when you only want to trigger an action.

Wrong: watching inside onPressed. That does not help and is confusing.

Wrong: reading in build for values you display. The UI will not rebuild when state changes.


### The Riverpod flow (shared data)

ProviderScope sits at the root. Inside it lives a provider such as numbersProvider or todoProvider. Home and other screens both watch that provider and both can call methods through the notifier.

No shared list is passed in constructors. Update on one screen, pop back, and the other screen already shows the new value.


### Riverpod folder organization

A clear Riverpod layout for a sample app:

lib/
  main.dart
  models/
  notifiers/
  providers/
  screens/
  widgets/
  services/
  router/

main.dart wraps the app with ProviderScope.

models/ holds immutable data classes with copyWith when needed.

notifiers/ holds StateNotifier, Notifier, or AsyncNotifier classes that own state and methods.

providers/ holds the provider declarations that connect notifiers to the UI. Sometimes notifier and provider live in the same file; splitting them is fine when files grow.

screens/ holds ConsumerWidget pages.

widgets/ holds smaller UI pieces. Prefer passing callbacks or watching providers only where needed.

services/ holds API, Firebase, or repository code with no Flutter UI.

router/ holds GoRouter setup when you add named navigation.

Sample app idea for Riverpod: the same Todo or numbers list, but every screen uses ref.watch and ref.read instead of constructor parameters.


### Minimum learning order

1. ProviderScope and ConsumerWidget
2. watch in build versus read in buttons
3. One shared NotifierProvider or StateNotifierProvider
4. Later: derived providers, then async and Firebase
5. Later still: code generation if you want less boilerplate


## 5. Providers without code generation

You can write Riverpod providers by hand. This is what beginners should learn first, and it is what this Todo project uses.

Manual pattern with StateNotifierProvider:

1. Create a notifier class that extends StateNotifier of your state type.
2. Put initial state in the constructor with super(...).
3. Write methods that assign state = a new value.
4. Declare a final provider that creates that notifier.

Example shape:

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void addTodo(String title) {
    final todo = Todo(...);
    state = [...state, todo];
  }
}

final todoProvider =
    StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

In the UI:

final todos = ref.watch(todoProvider);
ref.read(todoProvider.notifier).addTodo(title);

You wrote the provider yourself. Nothing generates files for you. This is clear and easy to debug.


### Other common manual provider types

Provider: for a simple value or object that does not change often, or for derived values.

StateProvider: for a tiny piece of mutable state such as a selected tab index. Fine for small cases. Prefer a notifier when logic grows.

NotifierProvider / StateNotifierProvider: for state with methods (CRUD, business rules).

FutureProvider: for a one-shot async load.

StreamProvider: for a continuous stream of values.

You pick the provider type based on the kind of data, not based on the screen name.


## 6. Providers with code generation

riverpod_generator writes provider code for you. You mark a function or class with @riverpod, then run the code generator. It creates a .g.dart file with the safe provider names.

Why people use generation:
- Less boilerplate.
- Consistent naming.
- Harder to make wiring mistakes.
- Cleaner when you have many providers.

Why learn manual first:
- You understand what the generator is producing.
- Debugging is easier when you know watch, read, and notifier by hand.
- Small apps do not need generation.

Typical generated flow:

1. Add riverpod_annotation, riverpod_generator, build_runner, and related packages.
2. Annotate a class or function with @riverpod.
3. Run: dart run build_runner build
4. Import the generated part file.
5. Use the generated provider name in the UI.

Naming convention: if your annotated state or class is named CounterState, the generated provider is often counterStateProvider. Riverpod follows a camelCase Provider suffix style.

Example idea with generation (counter):

@riverpod
class CounterState extends _$CounterState {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

Then in a ConsumerWidget:

final counterValue = ref.watch(counterStateProvider);
final counterNotifier = ref.read(counterStateProvider.notifier);

counterValue is the current number. counterNotifier gives increment, decrement, and reset.

Same mental model as manual providers: watch for UI, read for actions. Generation only changes how the provider is declared, not how you use ref.


### Manual versus generated: when to choose

Use manual providers while learning and for small features.

Use generation when the app grows and writing providers by hand becomes repetitive.

Do not mix styles randomly in one feature. Pick one approach per feature area and stay consistent.


## 7. StateNotifier and AsyncNotifier

### StateNotifier for CRUD state

StateNotifier owns a piece of state and exposes methods that change it. It is a strong fit for CRUD: create, read, update, delete.

In our Todo app, TodoNotifier extends StateNotifier of List of Todo.

Initial state is an empty list.

addTodo creates a Todo and sets state to a new list with that item.

removeTodo filters the list and assigns a new list without that id.

ToggleTodo maps the list and flips completed for the matching id using copyWith.

updateTodo maps the list and changes the title for the matching id.

Every method assigns state = something new. That assignment is what notifies Riverpod. Mutating the old list in place without reassigning often fails to update the UI.

CRUD rule of thumb:
- Create: append a new object into a new list.
- Read: the UI watches the provider; no special method required beyond exposing state.
- Update: map and copyWith for the matching item.
- Delete: where / filter into a new list.


### Why immutable updates matter

Prefer:

state = [...state, todo];

Avoid changing the existing list object in place and hoping listeners notice.

On models, prefer copyWith so you create a new Todo instead of mutating fields on the old one.


### AsyncNotifier for async state

AsyncNotifier is for state that loads or saves asynchronously. Its state is usually AsyncValue, which can be loading, data, or error.

Use AsyncNotifier when:
- You fetch todos from Firebase or an API.
- You need loading and error handling in one place.
- Mutations also talk to the network and then refresh local state.

Typical idea:

class TodosAsyncNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    return repository.fetchTodos();
  }

  Future<void> addTodo(String title) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.createTodo(title);
      return repository.fetchTodos();
    });
  }
}

In the UI you often write:

final asyncTodos = ref.watch(todosAsyncProvider);

asyncTodos.when(
  data: (todos) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);

StateNotifier is great for local in-memory CRUD (what this project has now).
AsyncNotifier is the next step when the same CRUD talks to Firebase or a backend.


## 8. FutureProvider and StreamProvider

These providers are for async data without always writing a full notifier class.


### FutureProvider

FutureProvider is for a one-time async read. Example: fetch a user profile once, or load a document.

Example idea:

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  return api.fetchProfile();
});

In the UI:

final profileAsync = ref.watch(userProfileProvider);

profileAsync.when(
  data: (profile) => Text(profile.name),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Failed'),
);

Use FutureProvider when you mainly need to load data and display it. If you also need many write methods, prefer AsyncNotifier.


### StreamProvider

StreamProvider listens to a stream and rebuilds when new values arrive. Example: Firestore snapshots, or auth state changes.

Example idea:

final todosStreamProvider = StreamProvider<List<Todo>>((ref) {
  return firestore
      .collection('todos')
      .snapshots()
      .map(...);
});

In the UI you still use when(data, loading, error), the same pattern as FutureProvider.

Use StreamProvider when the source already pushes updates over time. Use FutureProvider when you fetch once. Use AsyncNotifier when you need both async load and custom write methods.


### Working example mindset

Loading screen: show a spinner while AsyncLoading / loading.

Success: show the list or detail from data.

Failure: show a short error and maybe a retry that invalidates the provider.

ref.invalidate(provider) is a common way to ask Riverpod to run the future or stream again.


## 9. Navigation with GoRouter

State management and navigation are different jobs, but they work together.

Riverpod holds shared data. GoRouter holds which screen is visible and how routes are named.

You do not pass the todo list through route constructors. Screens open by path, then each screen watches todoProvider itself.


### Why GoRouter

Named routes become clear: /, /todos, /todos/:id.

Deep links and web URLs are easier.

Redirects can protect routes, for example send unauthenticated users to login.

Navigation logic can live in one router file instead of scattered Navigator.push calls.


### Folder organization for navigation

lib/router/app_router.dart can hold the GoRouter instance.

You can expose the router with a Riverpod provider if redirects need auth state:

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // send to /login when needed
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/todos', builder: (context, state) => const TodosScreen()),
      GoRoute(
        path: '/todos/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TodoDetailScreen(id: id);
        },
      ),
    ],
  );
});

In MaterialApp.router, use the router from that provider.


### Navigation flow with Riverpod

User opens HomeScreen. Home watches todoProvider and shows the list.

User taps a todo. App navigates with context.go('/todos/$id') or context.push(...).

Detail screen receives only the id from the route. It watches a provider such as todoByIdProvider(id), or finds the todo from the shared list provider.

User edits the todo through the notifier. Detail and list both stay in sync because they share Riverpod state, not because navigation passed a full object.

User pops or goes back. List already shows the update.


### What not to do

Do not pass large mutable objects through route constructors as your source of truth.

Do not store navigation history inside your TodoNotifier. Keep routing in GoRouter.

Do use setState only for local UI on a page, such as a text field focus or dialog open state.


## 10. Our Todo project today

This app uses Riverpod for a Todo list with manual providers (no code generation yet).

Files involved:
- lib/main.dart wraps the app with ProviderScope.
- lib/models/todo.dart defines a Todo with id, title, and completed, plus copyWith so we update by creating a new object instead of mutating the old one.
- lib/notifiers/todo_notifiers.dart holds TodoNotifier, which owns the list and methods to add, remove, toggle, and update todos.
- lib/providers/todo_provider.dart exposes todoProvider as a StateNotifierProvider so the UI can access TodoNotifier and the List of Todo.
- lib/screen/home_screen.dart is a ConsumerWidget that watches the list and calls notifier methods.
- The add dialog and todo tile are UI pieces. Local dialog text can still use setState. Shared todo data goes through Riverpod.


### How a tap flows in the Todo app

1. User taps the add button on HomeScreen.
2. A dialog asks for a title.
3. HomeScreen calls ref.read(todoProvider.notifier).addTodo(title).
4. addTodo creates a new Todo and sets state to a new list that includes it.
5. Riverpod detects the state change.
6. Widgets that watch todoProvider rebuild.
7. The list UI updates.

The same idea applies to delete, toggle, and edit: read the notifier, change state, watchers rebuild.


### Why we assign a new list

Inside TodoNotifier we do things like:

state = [...state, todo];

or build a new list with map and where.

We do not mutate the old list in place and hope listeners notice. Assigning a new state value is what tells Riverpod something changed.


### Why copyWith exists on Todo

Instead of doing todo.completed = true on an existing object, we create an updated copy with copyWith. That keeps state immutable, which is the recommended pattern with Riverpod.


## 11. Best practices

### Folder organization

Keep a predictable structure:

lib/
  main.dart
  models/
  notifiers/
  providers/
  screens/
  widgets/
  services/
  router/
  docs stay outside lib, for example docs/state_management.md

One feature can still span several folders. The rule is: UI in screens/widgets, state in notifiers/providers, IO in services, routes in router.


### State rules

Put shared state in Riverpod, not in widget fields you pass around.

Use watch for displayed values and read for actions.

Assign new state instead of mutating old objects in place.

Keep notifiers free of BuildContext and UI widgets. Return results or update state; let the widget show SnackBars and dialogs.


### Provider choice

Local dialog or animation: setState is fine.

Shared list with CRUD methods: StateNotifier or Notifier.

Async load with loading and error: FutureProvider, StreamProvider, or AsyncNotifier.

Many providers and lots of boilerplate: consider riverpod_generator.


### Navigation rules

Use GoRouter for screen flow.

Pass ids or simple route params, not whole mutable models as the source of truth.

Let each screen watch the providers it needs.


### Documentation habits

Keep a short project doc that explains:
- where providers live
- which provider is the source of truth
- how to run code generation if you use it
- how navigation paths map to screens

Update the doc when you add AsyncNotifier, Firebase, or GoRouter so the next reader does not guess.


### Performance habits

Watch only what the widget needs. Prefer smaller providers or selecting fields when a screen cares about one piece of a large state.

Do not put heavy work inside build. Put loading in notifiers, services, or providers.

Rebuild only ConsumerWidget or Consumer parts that depend on the changed provider.


## 12. Concepts in plain words

State management: keeping app UI data consistent and persistent across interactions and navigation.

Provider package: older common Flutter approach using ChangeNotifier and Consumer.

ChangeNotifier: a base class that can notify listeners when data changes.

Consumer: a widget that rebuilds when a Provider ChangeNotifier changes.

notifyListeners: the method that tells Consumers to rebuild.

MultiProvider: a wrapper that registers one or more providers at the root.

setState: Flutter’s local rebuild method. Good for local UI. Not enough for shared screen state by itself.

Riverpod: a modern state management library with ProviderScope, ref.watch, ref.read, and notifiers.

ProviderScope: the root warehouse that holds all Riverpod providers for the app.

ConsumerWidget: a Flutter widget that receives WidgetRef so it can watch and read providers.

WidgetRef / ref: the handle used to interact with providers from a widget.

ref.watch: subscribe to a provider and rebuild when it changes.

ref.read: access a provider once, usually to call a method.

ref.listen: react to changes with a side effect without using that value to build UI.

Notifier / StateNotifier: a class that owns state and exposes methods to change it.

AsyncNotifier: a notifier whose state is async (loading, data, error).

FutureProvider: provider for a one-shot Future.

StreamProvider: provider for a Stream of values.

Code generation: riverpod_generator writes provider boilerplate from @riverpod annotations.

GoRouter: declarative navigation that works well beside Riverpod.

todoProvider: our app’s single source of truth for the todo list.


## 13. Learning path checklist

Provider fundamentals: understand ChangeNotifier, MultiProvider, Consumer, folder layout, and a two-screen sample that shares state.

Riverpod state management: ProviderScope, ConsumerWidget, ref, watch, read, folder layout, and a sample app with one shared provider.

StateNotifier and AsyncNotifier: local CRUD with StateNotifier first, then async CRUD with AsyncNotifier and AsyncValue.when.

FutureProvider and StreamProvider: one working async load and one working stream example with loading and error UI.

Navigation: add GoRouter, watch providers on each screen, pass ids in routes, keep shared data in Riverpod.

Best practices: clean folders, clear docs, immutable state updates, correct watch/read usage, and a simple rule for when to use generation.


## 14. What to practice next

Stay comfortable with ProviderScope, ConsumerWidget, watch, and read first.

Then deepen the Todo notifier methods and maybe add a second screen that also watches todoProvider, with no constructor list.

After that, learn derived providers, for example a provider that only exposes completed todos.

Next, try FutureProvider or AsyncNotifier with Firebase so loading and error states become natural.

Then add GoRouter so Home and detail screens share Riverpod state through routes by id.

When the app grows, optionally introduce riverpod_generator for new providers while keeping the same watch and read habits.
