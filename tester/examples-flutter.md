# Flutter / Dart Test Examples

## 1. Unit Test — Dart Class

Testing a plain Dart service with mocked dependencies using `mockito`.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_app/services/user_service.dart';
import 'package:my_app/repositories/user_repository.dart';
import 'package:my_app/models/user.dart';

@GenerateMocks([UserRepository])
import 'user_service_test.mocks.dart';

void main() {
  late UserService service;
  late MockUserRepository mockRepo;

  setUp(() {
    mockRepo = MockUserRepository();
    service = UserService(repository: mockRepo);
  });

  group('getUser', () {
    test('should return user when found', () async {
      final user = User(id: 1, name: 'Alice');
      when(mockRepo.findById(1)).thenAnswer((_) async => user);

      final result = await service.getUser(1);

      expect(result, equals(user));
      verify(mockRepo.findById(1)).called(1);
    });

    test('should throw UserNotFoundException when not found', () async {
      when(mockRepo.findById(999)).thenAnswer((_) async => null);

      expect(
        () => service.getUser(999),
        throwsA(isA<UserNotFoundException>()),
      );
    });

    test('should throw on negative id', () {
      expect(
        () => service.getUser(-1),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('createUser', () {
    test('should call repository and return created user', () async {
      final newUser = User(id: 0, name: 'Bob');
      final created = User(id: 2, name: 'Bob');
      when(mockRepo.create(newUser)).thenAnswer((_) async => created);

      final result = await service.createUser(newUser);

      expect(result.id, equals(2));
      verify(mockRepo.create(newUser)).called(1);
    });
  });
}
```

**Key patterns:**
- `@GenerateMocks` + `build_runner` to generate typed mocks
- `setUp()` for fresh mocks per test
- `when().thenAnswer()` for async stubs (use `thenReturn()` for sync)
- `verify().called(1)` to assert interaction count
- `throwsA(isA<T>())` for exception assertions
- `group()` for logical test grouping

---

## 2. Widget Test

Testing a Flutter widget with user interaction and state changes.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/widgets/counter_widget.dart';

void main() {
  group('CounterWidget', () {
    testWidgets('should display initial count of zero', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget()),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should increment count when button is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget()),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should not go below zero when decrement is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget()),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should show snackbar when limit reached', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget(maxCount: 2)),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Maximum reached'), findsOneWidget);
    });
  });
}
```

**Key patterns:**
- Wrap widget in `MaterialApp` for theme/navigation context
- `tester.pumpWidget()` to render, `tester.pump()` to rebuild after state change
- `tester.pumpAndSettle()` to wait for all animations to complete
- `find.text()`, `find.byIcon()`, `find.byType()` for widget finders
- `findsOneWidget`, `findsNothing`, `findsNWidgets(n)` for matchers
- `tester.tap()`, `tester.enterText()`, `tester.drag()` for interactions

---

## 3. Widget Test with Mocked Dependencies

Testing a widget that depends on a service, using provider injection and mockito.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:my_app/screens/user_profile_screen.dart';
import 'package:my_app/services/user_service.dart';
import 'package:my_app/models/user.dart';

@GenerateMocks([UserService])
import 'user_profile_screen_test.mocks.dart';

void main() {
  late MockUserService mockUserService;

  setUp(() {
    mockUserService = MockUserService();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Provider<UserService>.value(
        value: mockUserService,
        child: const UserProfileScreen(userId: 1),
      ),
    );
  }

  group('UserProfileScreen', () {
    testWidgets('should show loading indicator initially', (tester) async {
      when(mockUserService.getUser(1)).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 1), () => User(id: 1, name: 'Alice')),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display user name after loading', (tester) async {
      when(mockUserService.getUser(1)).thenAnswer(
        (_) async => User(id: 1, name: 'Alice'),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show error message on failure', (tester) async {
      when(mockUserService.getUser(1)).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}
```

**Key patterns:**
- `createTestWidget()` helper wraps widget with providers and `MaterialApp`
- Inject mocked service via `Provider.value`
- Test loading, success, and error states
- `pumpAndSettle()` after async operations complete

---

## 4. Bloc Test

Testing a Bloc/Cubit using the `bloc_test` package.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_app/blocs/auth/auth_bloc.dart';
import 'package:my_app/blocs/auth/auth_event.dart';
import 'package:my_app/blocs/auth/auth_state.dart';
import 'package:my_app/repositories/auth_repository.dart';
import 'package:my_app/models/user.dart';

@GenerateMocks([AuthRepository])
import 'auth_bloc_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
  });

  group('AuthBloc', () {
    test('should have initial state as AuthInitial', () {
      final bloc = AuthBloc(authRepository: mockAuthRepo);
      expect(bloc.state, equals(AuthInitial()));
      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(mockAuthRepo.login('alice', 'pass123')).thenAnswer(
          (_) async => User(id: 1, name: 'Alice'),
        );
        return AuthBloc(authRepository: mockAuthRepo);
      },
      act: (bloc) => bloc.add(LoginRequested(username: 'alice', password: 'pass123')),
      expect: () => [
        AuthLoading(),
        isA<AuthAuthenticated>().having((s) => s.user.name, 'user name', 'Alice'),
      ],
      verify: (_) {
        verify(mockAuthRepo.login('alice', 'pass123')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] on failed login',
      build: () {
        when(mockAuthRepo.login(any, any)).thenThrow(Exception('Invalid credentials'));
        return AuthBloc(authRepository: mockAuthRepo);
      },
      act: (bloc) => bloc.add(LoginRequested(username: 'alice', password: 'wrong')),
      expect: () => [
        AuthLoading(),
        isA<AuthError>().having((s) => s.message, 'message', contains('Invalid')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthInitial] on logout',
      build: () {
        when(mockAuthRepo.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockAuthRepo);
      },
      seed: () => AuthAuthenticated(user: User(id: 1, name: 'Alice')),
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [AuthInitial()],
    );
  });
}
```

**Key patterns:**
- `blocTest` — declarative: `build`, `act`, `expect`, `verify`
- `seed` to set an initial state before acting
- `isA<T>().having()` for typed property assertions on emitted states
- `any` matcher from mockito for flexible argument matching
- Always test initial state separately with a plain `test()`

---

## 5. Model / Data Class Test

Testing JSON serialization and value equality.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/user.dart';

void main() {
  group('User', () => {
    final json = {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'};
    final user = User(id: 1, name: 'Alice', email: 'alice@example.com');

    test('should create from JSON', () {
      final result = User.fromJson(json);
      expect(result, equals(user));
    });

    test('should convert to JSON', () {
      expect(user.toJson(), equals(json));
    });

    test('should support value equality', () {
      final user2 = User(id: 1, name: 'Alice', email: 'alice@example.com');
      expect(user, equals(user2));
    });

    test('should have correct copyWith', () {
      final updated = user.copyWith(name: 'Bob');
      expect(updated.name, equals('Bob'));
      expect(updated.id, equals(user.id));
      expect(updated.email, equals(user.email));
    });
  });
}
```

**Key patterns:**
- Test `fromJson` / `toJson` round-trip
- Verify value equality (important for Equatable/freezed models)
- Test `copyWith` preserves unchanged fields
