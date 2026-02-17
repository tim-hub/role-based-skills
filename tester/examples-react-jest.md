# React / Jest / Redux Examples

## 1. React Component Test

Testing a component with user interactions, conditional rendering, and parameterized cases.

```tsx
// Multivariate Dependencies
import React from 'react';

// Components
import { WellnessHistoryMenu } from '../WellnessHistoryMenu';

// Utils
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

// Types
import { WellnessHistoryOptionLabels } from '../../types/WellnessHistoryOption';

describe('Wellness history menu component', () => {
  const mockPause = jest.fn();
  const mockChange = jest.fn();
  const mockRenew = jest.fn();
  const mockLock = jest.fn();
  const mockCancel = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  const renderMenu = () => {
    render(
      <WellnessHistoryMenu
        pause={mockPause}
        change={mockChange}
        renew={mockRenew}
        cancel={mockCancel}
        lock={mockLock}
        isBenefitLocked
        userPermissions={{ lockwellnessplanmemberships: true }}
      />
    );
  };

  it('should render the edit button', () => {
    renderMenu();
    expect(screen.getByRole('button', { name: 'Click to edit wellness history' })).toBeVisible();
  });

  it('should show all options when button is pressed', () => {
    renderMenu();
    userEvent.click(screen.getByRole('button', { name: 'Click to edit wellness history' }));

    expect(screen.getByText(WellnessHistoryOptionLabels.CANCEL)).toBeInTheDocument();
    expect(screen.getByText(WellnessHistoryOptionLabels.CHANGE)).toBeInTheDocument();
    expect(screen.getByText(WellnessHistoryOptionLabels.RENEW)).toBeInTheDocument();
  });

  // Parameterized test for similar cases
  it.each([
    [WellnessHistoryOptionLabels.PAUSE, mockPause],
    [WellnessHistoryOptionLabels.CANCEL, mockCancel],
    [WellnessHistoryOptionLabels.CHANGE, mockChange],
  ])('should call correct handler when %s is clicked', (optionLabel, mockFunction) => {
    renderMenu();
    userEvent.click(screen.getByRole('button', { name: 'Click to edit wellness history' }));
    userEvent.click(screen.getByText(optionLabel));
    expect(mockFunction).toHaveBeenCalledTimes(1);
  });

  // Testing absence of elements
  it('should not show lock option without permission', () => {
    render(
      <WellnessHistoryMenu
        pause={mockPause}
        change={mockChange}
        renew={mockRenew}
        cancel={mockCancel}
        lock={mockLock}
        userPermissions={{ lockwellnessplanmemberships: false }}
      />
    );
    userEvent.click(screen.getByRole('button', { name: 'Click to edit wellness history' }));
    expect(screen.queryByText(WellnessHistoryOptionLabels.LOCK)).toBeNull();
  });
});
```

**Key patterns:**
- Helper `renderMenu()` for repeated setup
- `jest.fn()` for callback props, `jest.clearAllMocks()` in `beforeEach`
- `it.each` for parameterized tests
- `screen.queryBy*` to assert element absence

---

## 2. Utility Function Test with Spies

Testing an async utility with mocked dependencies, success and error paths.

```typescript
// Utils
import { fetchUser } from '../fetchUser';
import * as fetchDataModule from '../fetchDataFromProtectedRoute/utils/fetchDataFromProtectedRoute';
import * as getHeadersModule from '../api/getBasicV3Headers';
import * as convertErrorModule from '../convertErrorObjectToString';

// Types
import { mockUser } from '@src/__mockData__/orm';

describe('fetchUser', () => {
  const mockHeaders = new Headers();
  const mockErrorMessage = 'test error';

  const fetchDataSpy = jest
    .spyOn(fetchDataModule, 'fetchDataFromProtectedRoute')
    .mockResolvedValue({ responseBody: { data: mockUser[0] }, error: undefined });

  const convertErrorSpy = jest
    .spyOn(convertErrorModule, 'convertErrorObjectToString')
    .mockReturnValue(mockErrorMessage);

  jest.spyOn(getHeadersModule, 'getBasicV3Headers').mockReturnValue(mockHeaders);
  const consoleErrorSpy = jest.spyOn(console, 'error');

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('successful requests', () => {
    it('should return user when found', async () => {
      expect(await fetchUser(mockUser[0].id)).toStrictEqual(mockUser[0]);
      expect(fetchDataSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          url: `/api/v3/users/${mockUser[0].id}`,
          headers: mockHeaders,
        })
      );
    });

    it('should return undefined when user not found', async () => {
      const mockResponse = { errors: [{ error: 'test' }] };
      fetchDataSpy.mockResolvedValueOnce({ responseBody: mockResponse, error: undefined });

      expect(await fetchUser(mockUser[0].id)).toBeUndefined();
      expect(convertErrorSpy).toHaveBeenCalledWith(mockResponse.errors);
      expect(consoleErrorSpy).toHaveBeenCalledWith(mockErrorMessage);
    });
  });

  describe('errors', () => {
    it('should log error when fetch fails', async () => {
      const mockError = new Error('Fetch failed');
      fetchDataSpy.mockResolvedValueOnce({ response: undefined, error: mockError });

      expect(await fetchUser(mockUser[0].id)).toBeUndefined();
      expect(consoleErrorSpy).toHaveBeenCalledWith(mockErrorMessage);
    });
  });
});
```

**Key patterns:**
- `jest.spyOn()` with `import * as module` for function spying
- `mockResolvedValue` for default, `mockResolvedValueOnce` for per-test overrides
- Reuse mock data from `@src/__mockData__/orm`
- `expect.objectContaining()` for partial argument matching
- Nested `describe` blocks for logical grouping (success vs error)

---

## 3. Redux Saga Test

Testing saga watchers and workers with `redux-saga-test-plan`.

```javascript
// Utils
import { expectSaga, testSaga } from 'redux-saga-test-plan';
import { replaceFirstTab, preCloseOtherViews, preReplaceView } from '../../../actions/views/views';
import { replaceFirstTabWatcher, resetViewsWatcher, resetViewsWorker } from '../views';
import { getFirstTabViewId } from '@main/utils/getFirstTabViewId';
import { getActiveModule } from '../../../selectors/base/base';
import { setActiveModule } from '../../../actions/base/base';

// Types
import { VIEW_ACTION_TYPES } from '@main/types/views/ViewActionTypes';
import TEST_STATE from '../../../../../__mockData__/testState';

describe('View requests sagas', () => {
  // expectSaga: integration-style, dispatches actions and asserts effects
  it('should replace first tab', () => {
    const viewId = 1;
    const recordClass = 'User';
    const recordId = 1;
    return expectSaga(replaceFirstTabWatcher)
      .withState(TEST_STATE)
      .put(preReplaceView(viewId, { recordClass, recordId }))
      .dispatch(replaceFirstTab({ recordClass, recordId }))
      .silentRun();
  });

  describe('resetViews', () => {
    // testSaga: unit-style, step-by-step verification
    it('should watch for reset actions', () => {
      testSaga(resetViewsWatcher)
        .next()
        .takeEvery(VIEW_ACTION_TYPES.resetViews, resetViewsWorker)
        .finish();
    });

    it('should close other views and reset module', () => {
      const firstTabId = 1;
      const activeModule = 'test';
      return testSaga(resetViewsWorker)
        .next()
        .select(getFirstTabViewId)
        .next(firstTabId)
        .put(preCloseOtherViews(firstTabId))
        .next()
        .select(getActiveModule)
        .next(activeModule)
        .put(setActiveModule(activeModule))
        .next()
        .isDone();
    });
  });
});
```

**Key patterns:**
- `expectSaga` with `.withState()` for integration tests against real state shape
- `testSaga` with `.next()` chain for step-by-step saga unit tests
- `.silentRun()` to suppress timeout warnings
- `.finish()` / `.isDone()` to assert saga completion
- Import test state from `__mockData__/testState`

---

## 4. Component with Providers

When a component needs Redux or MUI providers:

```tsx
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { renderWithMuiAndReduxProvider } from '../../test-utils';
import { MyConnectedComponent } from '../MyConnectedComponent';

describe('MyConnectedComponent', () => {
  it('should render with providers', () => {
    renderWithMuiAndReduxProvider(<MyConnectedComponent />);
    expect(screen.getByText('Expected Text')).toBeInTheDocument();
  });
});
```

Available render helpers from `src/records/components/test-utils.js`:
- `renderWithMuiWrapper` — wraps with MUI ThemeProvider
- `renderWithReduxWrapper` — wraps with Redux Provider (empty mock store)
- `renderWithMuiAndReduxProvider` — wraps with both

---

## 5. Module-Level Mocking

When you need to mock an entire module (e.g., feature flags):

```typescript
// Must be at top level, before imports that use the mocked module
jest.mock('@records/utils/isFeatureEnabled', () => ({
  isFeatureEnabled: jest.fn().mockReturnValue(true),
}));

// Then import and use in tests
import { isFeatureEnabled } from '@records/utils/isFeatureEnabled';

describe('feature-gated component', () => {
  it('should render when feature is enabled', () => {
    // Default mock returns true
    renderComponent();
    expect(screen.getByText('Feature Content')).toBeInTheDocument();
  });

  it('should not render when feature is disabled', () => {
    (isFeatureEnabled as jest.Mock).mockReturnValueOnce(false);
    renderComponent();
    expect(screen.queryByText('Feature Content')).toBeNull();
  });
});
```
