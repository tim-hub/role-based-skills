# Python (pytest) Examples

## 1. Service Function Test with Fixtures

Testing a service with mocked dependencies using pytest fixtures and `unittest.mock`.

```python
import pytest
from unittest.mock import MagicMock, patch
from app.services.user_service import UserService, UserNotFoundError


@pytest.fixture
def mock_user_repo():
    return MagicMock()


@pytest.fixture
def user_service(mock_user_repo):
    return UserService(user_repo=mock_user_repo)


class TestUserService:
    def test_get_user_returns_user_when_exists(self, user_service, mock_user_repo):
        mock_user_repo.find_by_id.return_value = {"id": 1, "name": "Alice"}

        result = user_service.get_user(1)

        assert result == {"id": 1, "name": "Alice"}
        mock_user_repo.find_by_id.assert_called_once_with(1)

    def test_get_user_raises_when_not_found(self, user_service, mock_user_repo):
        mock_user_repo.find_by_id.return_value = None

        with pytest.raises(UserNotFoundError, match="User 999 not found"):
            user_service.get_user(999)

    @pytest.mark.parametrize("email", ["", "not-an-email", "missing@"])
    def test_create_user_rejects_invalid_email(self, user_service, email):
        with pytest.raises(ValueError, match="Invalid email"):
            user_service.create_user(name="Alice", email=email)

    @patch("app.services.user_service.send_welcome_email")
    def test_create_user_sends_welcome_email(
        self, mock_send_email, user_service, mock_user_repo
    ):
        mock_user_repo.find_by_email.return_value = None
        mock_user_repo.create.return_value = {"id": 1, "email": "a@b.com"}

        user_service.create_user(name="Alice", email="a@b.com")

        mock_send_email.assert_called_once_with("a@b.com")
```

**Key patterns:**
- `@pytest.fixture` for dependency setup — composable and reusable
- `MagicMock()` for repository stubs
- `assert_called_once_with()` for verifying interactions
- `pytest.raises` as context manager for exception testing
- `@pytest.mark.parametrize` for data-driven tests
- `@patch` to mock module-level functions

---

## 2. Async Function Test

Testing async code with `pytest-asyncio`.

```python
import pytest
from unittest.mock import AsyncMock, patch
from app.services.notification_service import NotificationService


@pytest.fixture
def mock_http_client():
    client = AsyncMock()
    client.post.return_value = {"status": "sent"}
    return client


@pytest.fixture
def notification_service(mock_http_client):
    return NotificationService(http_client=mock_http_client)


class TestNotificationService:
    @pytest.mark.asyncio
    async def test_send_notification_calls_api(
        self, notification_service, mock_http_client
    ):
        await notification_service.send("user-123", "Hello!")

        mock_http_client.post.assert_awaited_once_with(
            "/notifications",
            json={"user_id": "user-123", "message": "Hello!"},
        )

    @pytest.mark.asyncio
    async def test_send_notification_retries_on_failure(
        self, notification_service, mock_http_client
    ):
        mock_http_client.post.side_effect = [
            ConnectionError("timeout"),
            {"status": "sent"},
        ]

        await notification_service.send("user-123", "Hello!")

        assert mock_http_client.post.await_count == 2
```

**Key patterns:**
- `AsyncMock` for async dependencies
- `@pytest.mark.asyncio` to enable async tests
- `assert_awaited_once_with()` for async call verification
- `side_effect` list for simulating retries
