---
name: tester
description: Write unit tests for code changes across multiple stacks including JavaScript/TypeScript (Jest, Vitest), React (Testing Library), PHP (PHPUnit), Python (pytest), Django (TestCase), Hono.js, Express.js, and Flutter (Dart). Use when the user asks to write tests, add test coverage, create unit tests, or when making code changes that need test coverage. Automatically suggests tests for new or modified code.
---

# Unit Test Writer

Write unit tests that uphold these principles:

1. **Fast feedback** - Tests run quickly and give immediate confidence.
2. **Safety net** - Prove the code works as intended.
3. **Reduce cost** - Catch issues early, minimize rework.
4. **Regression coverage** - Prevent fixed bugs from resurfacing.
5. **Automation-ready** - Deterministic, runnable in CI.
6. **Maintenance-friendly** - Future changes are easy to verify.
7. **Isolated** - Mock all external dependencies; never rely on remote services.

## Workflow

```
Task Progress:
- [ ] Step 1: Analyze the code under test
- [ ] Step 2: Identify the test location and type
- [ ] Step 3: Discover existing test utilities and mock data
- [ ] Step 4: Write the test
- [ ] Step 5: Run and verify the test passes
```

### Step 1: Analyze the code under test

Before writing any test:

1. Read the source file thoroughly.
2. Identify all code paths: happy path, edge cases, error handling.
3. List external dependencies that need mocking.
4. Check what the function/component receives (props, args) and returns/renders.

### Step 2: Identify test location and type

**File placement** - Always check for a nearby `tests/` or `__tests__/` folder first and follow the same convention. If no existing pattern, use the stack default:

| Stack | Convention |
|-------|-----------|
| **JS/TS (Jest/Vitest)** | `__tests__/Foo.test.ts` or `tests/Foo.test.ts` next to source |
| **PHP (PHPUnit)** | `tests/Unit/`, `tests/Feature/` mirroring `src/` or `app/` structure |
| **Python (pytest)** | `tests/` directory mirroring source, prefixed `test_*.py` |
| **Django** | `tests/` inside each app, or `app/tests/test_*.py` |
| **Hono.js** | `src/**/*.test.ts` or `tests/*.test.ts` (Vitest) |
| **Express.js** | `__tests__/` or `tests/` with `*.test.js` / `*.spec.js` |
| **Flutter (Dart)** | `test/` directory mirroring `lib/`, suffixed `_test.dart` |

**Test type decision by stack:**

| What you're testing | Framework / Tool |
|--------------------|--------------------|
| React component | `@testing-library/react` + `userEvent` |
| JS/TS utility function | Direct calls with Jest/Vitest assertions |
| Redux saga | `redux-saga-test-plan` (`expectSaga` / `testSaga`) |
| React hook | `@testing-library/react-hooks` (`renderHook`) |
| Express route/middleware | `supertest` + Jest |
| Hono route/middleware | `app.request()` or `@hono/node-server` + Vitest |
| PHP class/service | PHPUnit `TestCase` with `setUp()` / `tearDown()` |
| Python function/class | pytest with fixtures and `unittest.mock` |
| Django view/model | `django.test.TestCase` with `Client` |
| Flutter widget | `flutter_test` with `testWidgets`, `WidgetTester`, `find` |
| Dart class/function | `test` package with `group`, `test`, `expect` |
| Flutter Bloc/Cubit | `bloc_test` with `blocTest` |

### Step 3: Discover existing utilities and mock data

Before writing mocks from scratch, search the project for existing resources:

- **Test helpers/utilities**: Look for `test-utils`, `conftest.py`, `TestCase` base classes, `setUp` files
- **Mock data / fixtures**: Look for `__mockData__/`, `fixtures/`, `factories/`, `conftest.py`, `*Factory.php`
- **Setup files**: `setupTests.js`, `conftest.py`, `TestCase::setUp()`, `phpunit.xml`
- **Existing mocks**: `__mocks__/`, `unittest.mock`, Mockery, test doubles

Reuse existing mock data and test utilities. Only create new mocks when no suitable ones exist.

### Step 4: Write the test

Follow these conventions:

#### Structure

```typescript
// Multivariate Dependencies
import React from 'react';

// Components
import { MyComponent } from '../MyComponent';

// Utils
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

// Types
import { SomeType } from '../../types/SomeType';

describe('MyComponent', () => {
  // Setup mocks at describe scope
  const mockHandler = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // Optional: helper render function for repeated setup
  const renderComponent = (overrides = {}) => {
    const defaultProps = { onSubmit: mockHandler, ...overrides };
    return render(<MyComponent {...defaultProps} />);
  };

  it('should render the submit button', () => {
    renderComponent();
    expect(screen.getByRole('button', { name: 'Submit' })).toBeVisible();
  });

  it('should call onSubmit when clicked', () => {
    renderComponent();
    userEvent.click(screen.getByRole('button', { name: 'Submit' }));
    expect(mockHandler).toHaveBeenCalledTimes(1);
  });
});
```

#### Import grouping

Follow the existing convention with comment headers:

```typescript
// Multivariate Dependencies
// Components
// Utils
// Types
```

#### Naming conventions

- `describe` block: Component/function name
- `it` block: Start with "should" — describe the expected behavior
- Use `it.each` for parameterized tests over multiple similar cases

#### Mocking rules

1. Use `jest.mock()` for module-level mocks (at file top, outside describe).
2. Use `jest.spyOn()` for spying on specific functions while preserving others.
3. Use `jest.fn()` for callback/handler props.
4. Call `jest.clearAllMocks()` in `beforeEach`.
5. Use `mockReturnValue` / `mockResolvedValue` for default mocks; use `mockReturnValueOnce` / `mockResolvedValueOnce` for per-test overrides.

#### Assertions

- Prefer `@testing-library/jest-dom` matchers: `toBeVisible()`, `toBeInTheDocument()`, `toHaveTextContent()`.
- Use `screen.getByRole()` over `getByTestId()` — query by accessibility role first.
- Use `screen.queryBy*()` to assert absence (returns `null`).
- Use `toStrictEqual()` for deep object comparison.
- Use `expect.objectContaining()` for partial matching.
- Use `toHaveBeenCalledWith()` to verify mock call arguments.

#### Components requiring providers

Use existing test utilities from `src/records/components/test-utils.js`:

- `renderWithMuiWrapper` — MUI ThemeProvider
- `renderWithReduxWrapper` — Redux Provider with mock store
- `renderWithMuiAndReduxProvider` — Both providers

#### Redux saga tests

Use `redux-saga-test-plan`:

- `expectSaga` for integration-style tests (with `.withState()`, `.dispatch()`, `.put()`)
- `testSaga` for step-by-step unit tests (`.next()`, `.select()`, `.put()`, `.isDone()`)

### Step 5: Run and verify

Run the test to confirm it passes. Use the appropriate command for the stack:

```bash
# JS/TS (Jest)
npx jest --testPathPattern="path/to/test" --no-coverage

# JS/TS (Vitest)
npx vitest run path/to/test

# PHP (PHPUnit)
./vendor/bin/phpunit --filter=TestClassName tests/Unit/path/to/Test.php

# Python (pytest)
python -m pytest tests/path/to/test_file.py -v

# Django
python manage.py test app.tests.test_module.TestClassName -v 2

# Flutter (Dart)
flutter test test/path/to/file_test.dart
```

If tests fail, read the error output, fix the issue, and rerun. Do not leave failing tests.

## When suggesting tests for code changes

When making code changes (not explicitly asked for tests), proactively suggest test coverage by:

1. Noting which functions/components were added or modified.
2. Briefly listing what should be tested (happy path, edge cases, error handling).
3. Offering to write the tests.

Do not auto-generate tests without the user's consent unless they explicitly asked for tests.

## Anti-patterns to avoid

- Never test implementation details (internal state, private methods).
- Never use `snapshot` tests for new tests unless explicitly requested.
- Never import from `enzyme` — use `@testing-library/react` for React.
- Never hardcode magic strings — import constants/enums from source.
- Never write tests that depend on test execution order.
- Never make real network requests — mock all API calls and external services.
- Never use `setTimeout`/`setInterval` in tests — use fake timers if timing logic needs testing.
- Never use the real database in unit tests — use mocks, fakes, or in-memory SQLite.
- Never use `sleep()` or real delays — use deterministic assertions.

## Examples by stack

Read only the file relevant to the current project's stack:

- [examples-react-jest.md](examples-react-jest.md) — React, Jest, Redux Saga, Testing Library
- [examples-php.md](examples-php.md) — PHP, PHPUnit
- [examples-python.md](examples-python.md) — Python, pytest, async
- [examples-django.md](examples-django.md) — Django models, views, API
- [examples-hono.md](examples-hono.md) — Hono.js, Vitest
- [examples-express.md](examples-express.md) — Express.js, Supertest, Jest
- [examples-flutter.md](examples-flutter.md) — Flutter, Dart, widget tests, Bloc
