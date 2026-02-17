# Django Test Examples

## 1. Model Test

Testing model methods and validation.

```python
import pytest
from django.core.exceptions import ValidationError
from orders.models import Order, OrderItem


@pytest.mark.django_db
class TestOrder:
    def test_total_price_sums_items(self):
        order = Order.objects.create(customer_name="Alice")
        OrderItem.objects.create(order=order, product_name="Widget", price=10, quantity=3)
        OrderItem.objects.create(order=order, product_name="Gadget", price=25, quantity=1)

        assert order.total_price == 55

    def test_empty_order_has_zero_total(self):
        order = Order.objects.create(customer_name="Bob")
        assert order.total_price == 0

    def test_cannot_create_order_without_customer_name(self):
        order = Order(customer_name="")
        with pytest.raises(ValidationError):
            order.full_clean()
```

**Key patterns:**
- `@pytest.mark.django_db` to enable database access (uses test DB, rolled back per test)
- Test model methods with real ORM calls against test database
- `full_clean()` to trigger model validation

---

## 2. View / API Test

Testing views with Django test `Client` or DRF's `APIClient`.

```python
import pytest
from django.test import Client
from django.urls import reverse
from unittest.mock import patch


@pytest.fixture
def client():
    return Client()


@pytest.fixture
def authenticated_client(client, django_user_model):
    user = django_user_model.objects.create_user(username="testuser", password="pass")
    client.force_login(user)
    return client


@pytest.mark.django_db
class TestOrderAPI:
    def test_list_orders_requires_auth(self, client):
        response = client.get(reverse("order-list"))
        assert response.status_code == 302  # redirect to login

    def test_list_orders_returns_user_orders(self, authenticated_client):
        response = authenticated_client.get(reverse("order-list"))
        assert response.status_code == 200
        assert "orders" in response.context

    @patch("orders.views.PaymentGateway.charge")
    def test_create_order_charges_payment(self, mock_charge, authenticated_client):
        mock_charge.return_value = {"transaction_id": "txn-123"}

        response = authenticated_client.post(
            reverse("order-create"),
            data={"product_id": 1, "quantity": 2},
        )

        assert response.status_code == 302  # redirect after success
        mock_charge.assert_called_once()

    def test_create_order_returns_error_on_invalid_data(self, authenticated_client):
        response = authenticated_client.post(
            reverse("order-create"),
            data={"product_id": "", "quantity": -1},
        )

        assert response.status_code == 200  # re-renders form
        assert "errors" in response.context or response.context["form"].errors
```

**Key patterns:**
- `Client()` / `force_login()` for authenticated requests
- `reverse()` for URL resolution — never hardcode URLs
- `@patch` to mock external services (payment gateway)
- Test auth requirements, success, and validation failure paths
