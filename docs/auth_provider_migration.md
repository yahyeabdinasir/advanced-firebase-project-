# AuthProvider Migration — From Local `setState` to Provider

**Branch:** `advanced_state_manegment`  
**Commit:** `69adf12` — *migrated from the etState to the provider*  
**Package:** [`provider`](https://pub.dev/packages/provider) `^6.1.5` (classic Provider, not Riverpod)

This document summarizes what changed when the app moved from per-screen Firebase auth (`AuthService()` + `setState` / `StreamBuilder`) to a shared `AuthProvider` (`ChangeNotifier`).

---

## Why we migrated

| Problem before | Solution after |
|----------------|----------------|
| Every screen created its own `AuthService()` | One shared `AuthService` from `MultiProvider` |
| Loading / errors lived in each screen’s `setState` | Loading / errors live in `AuthProvider` |
| `AuthGate` used `StreamBuilder` + local service | `AuthGate` watches `AuthProvider` |
| Auth state duplicated across widgets | Single source of truth: `_user` in `AuthProvider` |

Goal: **UI listens; Provider owns auth state; Service talks to Firebase.**

```text
UI (Login / Signup / Home / AuthGate)
        ↓  context.read / context.watch
AuthProvider  (ChangeNotifier — user, loading, error)
        ↓  calls
AuthService   (Firebase Auth only)
```

---

## Files changed on this branch

| File | Change |
|------|--------|
| `pubspec.yaml` / `pubspec.lock` | Added `provider: ^6.1.5` |
| `lib/providers/auth_provider.dart` | **New** — central auth state |
| `lib/main.dart` | Wrapped app with `MultiProvider` |
| `lib/widget/auth_gate.dart` | `StreamBuilder` → `context.watch<AuthProvider>()` |
| `lib/screen/login_screen.dart` | Removed local `AuthService` / `_isLoading`; uses Provider |
| `lib/screen/signup_screen.dart` | Same for register; still creates Firestore user + FCM |
| `lib/screen/home_screen.dart` | User + logout via Provider |

Unchanged responsibilities:

- `AuthService` — Firebase login / register / logout / stream
- `UserService` — Firestore profile create / get
- `FcmService` / `LocalPrefsService` — still called from screens after success

---

## Before vs after (architecture)

### Before (no Provider)

```text
main.dart
  └── MaterialApp → AuthGate
                        ├── AuthService()          ← new instance
                        └── StreamBuilder(authStateChanges)
                              ├── LoginScreen → AuthService() + setState(_isLoading)
                              ├── SignupScreen → AuthService() + setState(_isLoading)
                              └── HomeScreen → AuthService() for user / logout
```

Each screen owned:

- Its own `AuthService()`
- Local `bool _isLoading`
- Local `try/catch` + SnackBar for auth errors

`AuthGate` decided login vs home with `StreamBuilder` on a **new** `AuthService()` instance.

### After (with Provider)

```text
main.dart
  └── MultiProvider
        ├── Provider<AuthService>              ← one shared instance
        └── ChangeNotifierProvider<AuthProvider>
              └── MaterialApp → AuthGate
                    └── context.watch<AuthProvider>()
                          ├── isInitializing → spinner
                          ├── isLoggedIn → HomeScreen
                          └── else → LoginScreen
```

Screens no longer create `AuthService()`. They call:

- `context.read<AuthProvider>()` — one-shot actions (`login`, `register`, `logout`)
- `context.watch<AuthProvider>()` — rebuild when loading / user changes

---

## What `AuthProvider` does

**Path:** `lib/providers/auth_provider.dart`  
**Base class:** `ChangeNotifier`

### Construction & stream subscription

```dart
AuthProvider(this._authService) {
  _authSubscription = _authService.authStateChanges.listen((user) {
    _user = user;
    _isInitializing = false;
    notifyListeners();
  });
}
```

| Step | Meaning |
|------|---------|
| Inject `AuthService` | Same instance as `ctx.read<AuthService>()` in `main` |
| Listen to `authStateChanges` | Firebase tells us signed-in `User?` or `null` |
| Set `_isInitializing = false` | First emission → AuthGate can leave the spinner |
| `notifyListeners()` | Rebuild widgets that `watch` this provider |
| `dispose()` cancels subscription | Avoid leaks when provider is disposed |

### Public API

| Getter / method | Role |
|-----------------|------|
| `user` | Current Firebase `User?` |
| `isLoggedIn` | `_user != null` (used by AuthGate) |
| `isInitializing` | `true` until first stream event |
| `isLoading` | Login / register in progress |
| `errorMessage` | Last auth error (human-readable) |
| `login(...)` → `Future<bool>` | Success/fail so Login can still run prefs + FCM |
| `register(...)` → `Future<UserCredential?>` | Credential so Signup can still write Firestore |
| `logout()` | Signs out via service; stream clears `_user` |
| `clearError()` | Clears `errorMessage` |

### Login / register pattern

1. `_isLoading = true` → `notifyListeners()`
2. Call `AuthService`
3. On error → set `_errorMessage`
4. Always clear loading → `notifyListeners()`
5. Return `bool` / `UserCredential?` to the screen

---

## Screen-by-screen migration

### `AuthGate`

| Before | After |
|--------|-------|
| `AuthService()` + `StreamBuilder` | `context.watch<AuthProvider>()` |
| Waiting → spinner (or cached user) | `isInitializing` → spinner |
| `snapshot.hasData` → Home | `isLoggedIn` → Home |
| else → Login | else → Login |

### `LoginScreen`

| Before | After |
|--------|-------|
| `final AuthService _authService = AuthService()` | Removed |
| Local `_isLoading` + `setState` | `auth.isLoading` from Provider |
| `try/catch` Firebase errors in screen | Errors mapped inside `AuthProvider` |
| `await _authService.login(...)` | `await context.read<AuthProvider>().login(...)` |

**Still in the screen after success:**

- `LocalPrefsService.saveEmail(...)`
- `FcmService.SetUpaAfterLogin()`

### `SignupScreen`

| Before | After |
|--------|-------|
| Local `AuthService` + `_isLoading` | `auth.register(...)` + `auth.isLoading` |
| Auth errors caught in screen | Auth errors via `auth.errorMessage` |
| Firestore + FCM after credential | Unchanged flow after `UserCredential?` |

**Note:** Signup imports Firebase with `hide AuthProvider` because Firebase Auth also exports a type named `AuthProvider`. Our class is `lib/providers/auth_provider.dart`.

### `HomeScreen`

| Before | After |
|--------|-------|
| `_authService.currentUser` | `context.watch/read<AuthProvider>().user` |
| `_authService.logout()` | `context.read<AuthProvider>().logout()` |
| `UserService` for profile | Unchanged |

---

## Wiring in `main.dart`

```dart
return MultiProvider(
  providers: [
    Provider(create: (_) => AuthService()),
    ChangeNotifierProvider(
      create: (ctx) => AuthProvider(ctx.read<AuthService>()),
    ),
  ],
  child: MaterialApp(
    home: const AuthGate(),
    // ...
  ),
);
```

- `Provider` → plain service (no listening needed)
- `ChangeNotifierProvider` → auth UI state; widgets rebuild on `notifyListeners()`
- Dependency injection: `AuthProvider` receives the same `AuthService` via `ctx.read`

---

## What did *not* move into Provider (by design)

These stay in the screens so `AuthProvider` stays focused on auth only:

- SharedPreferences (save / load email)
- FCM permission + token after login/signup
- Firestore user document create / load (`UserService`)

Later (optional): a separate `ProfileProvider` for Firestore profile state.

---

## How to verify

1. Cold start → spinner briefly → Login or Home (session restore)
2. Login success → prefs + FCM still run → Home
3. Wrong password → SnackBar from `errorMessage`, button loading clears
4. Signup → Firebase user + Firestore profile → back / Home
5. Logout → AuthGate shows Login again

---

## Quick glossary

| Term | Meaning here |
|------|----------------|
| **Provider (package)** | Flutter state package used in this branch |
| **Riverpod** | Different library — **not** used here |
| **`context.watch`** | Subscribe + rebuild when notifier changes |
| **`context.read`** | One-shot access (events / methods), no rebuild from that call |
| **`ChangeNotifier`** | Calls `notifyListeners()` so watchers rebuild |
| **`AuthService`** | Thin Firebase Auth wrapper |
| **`AuthProvider`** | App auth state + loading/errors on top of the service |
