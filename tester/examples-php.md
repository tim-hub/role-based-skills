# PHP (PHPUnit) Examples

## 1. Service Class Test

Testing a service with mocked repository dependency.

```php
<?php

namespace Tests\Unit\Services;

use App\Models\User;
use App\Repositories\UserRepository;
use App\Services\UserService;
use PHPUnit\Framework\MockObject\MockObject;
use PHPUnit\Framework\TestCase;

class UserServiceTest extends TestCase
{
    private UserService $service;
    private UserRepository&MockObject $userRepository;

    protected function setUp(): void
    {
        parent::setUp();
        $this->userRepository = $this->createMock(UserRepository::class);
        $this->service = new UserService($this->userRepository);
    }

    public function test_find_user_returns_user_when_exists(): void
    {
        $user = new User(['id' => 1, 'name' => 'Alice']);

        $this->userRepository
            ->expects($this->once())
            ->method('findById')
            ->with(1)
            ->willReturn($user);

        $result = $this->service->findUser(1);

        $this->assertSame($user, $result);
    }

    public function test_find_user_returns_null_when_not_found(): void
    {
        $this->userRepository
            ->expects($this->once())
            ->method('findById')
            ->with(999)
            ->willReturn(null);

        $this->assertNull($this->service->findUser(999));
    }

    public function test_create_user_throws_on_duplicate_email(): void
    {
        $this->userRepository
            ->method('findByEmail')
            ->with('alice@example.com')
            ->willReturn(new User(['email' => 'alice@example.com']));

        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Email already registered');

        $this->service->createUser('Alice', 'alice@example.com');
    }

    /**
     * @dataProvider invalidEmailProvider
     */
    public function test_create_user_rejects_invalid_email(string $email): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->service->createUser('Alice', $email);
    }

    public static function invalidEmailProvider(): array
    {
        return [
            'empty string' => [''],
            'missing @' => ['alice-example.com'],
            'missing domain' => ['alice@'],
        ];
    }
}
```

**Key patterns:**
- `setUp()` to instantiate mocks and system under test
- `createMock()` for dependency injection
- `expects($this->once())` to verify call count
- `willReturn()` / `willThrowException()` for stubbing
- `@dataProvider` for parameterized tests
- `expectException()` declared before the triggering call

---

## 2. Controller Test

Testing a controller action with mocked service layer.

```php
<?php

namespace Tests\Unit\Controllers;

use App\Controllers\OrderController;
use App\DTOs\CreateOrderRequest;
use App\Services\OrderService;
use PHPUnit\Framework\MockObject\MockObject;
use PHPUnit\Framework\TestCase;

class OrderControllerTest extends TestCase
{
    private OrderController $controller;
    private OrderService&MockObject $orderService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->orderService = $this->createMock(OrderService::class);
        $this->controller = new OrderController($this->orderService);
    }

    public function test_store_returns_created_response(): void
    {
        $request = new CreateOrderRequest(['product_id' => 1, 'quantity' => 2]);
        $expectedOrder = ['id' => 42, 'product_id' => 1, 'quantity' => 2];

        $this->orderService
            ->expects($this->once())
            ->method('create')
            ->with($this->callback(fn ($arg) =>
                $arg->productId === 1 && $arg->quantity === 2
            ))
            ->willReturn($expectedOrder);

        $response = $this->controller->store($request);

        $this->assertEquals(201, $response->getStatusCode());
        $this->assertEquals($expectedOrder, $response->getData());
    }

    public function test_store_returns_422_on_validation_failure(): void
    {
        $this->orderService
            ->method('create')
            ->willThrowException(new \App\Exceptions\ValidationException('Invalid quantity'));

        $request = new CreateOrderRequest(['product_id' => 1, 'quantity' => -1]);
        $response = $this->controller->store($request);

        $this->assertEquals(422, $response->getStatusCode());
    }
}
```

**Key patterns:**
- `$this->callback()` for complex argument matching
- Test both success (201) and validation failure (422) paths
- Never hit real HTTP — test controller as a plain class
