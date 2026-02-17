# Hono.js (Vitest) Examples

## 1. Route Handler Test

Testing Hono route handlers using the built-in `app.request()` test helper.

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { userRoutes } from '../routes/users';
import type { UserService } from '../services/userService';

describe('User Routes', () => {
  let app: Hono;
  let mockUserService: UserService;

  beforeEach(() => {
    mockUserService = {
      findById: vi.fn(),
      create: vi.fn(),
      delete: vi.fn(),
    } as unknown as UserService;

    app = new Hono();
    userRoutes(app, mockUserService);
  });

  describe('GET /users/:id', () => {
    it('should return user when found', async () => {
      const mockUser = { id: '1', name: 'Alice', email: 'alice@example.com' };
      vi.mocked(mockUserService.findById).mockResolvedValue(mockUser);

      const res = await app.request('/users/1');
      const body = await res.json();

      expect(res.status).toBe(200);
      expect(body).toEqual(mockUser);
      expect(mockUserService.findById).toHaveBeenCalledWith('1');
    });

    it('should return 404 when user not found', async () => {
      vi.mocked(mockUserService.findById).mockResolvedValue(null);

      const res = await app.request('/users/999');

      expect(res.status).toBe(404);
      expect(await res.json()).toEqual({ error: 'User not found' });
    });
  });

  describe('POST /users', () => {
    it('should create user and return 201', async () => {
      const newUser = { name: 'Bob', email: 'bob@example.com' };
      const createdUser = { id: '2', ...newUser };
      vi.mocked(mockUserService.create).mockResolvedValue(createdUser);

      const res = await app.request('/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newUser),
      });

      expect(res.status).toBe(201);
      expect(await res.json()).toEqual(createdUser);
    });

    it('should return 400 on invalid body', async () => {
      const res = await app.request('/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: '' }),
      });

      expect(res.status).toBe(400);
    });
  });
});
```

**Key patterns:**
- `app.request()` — Hono's built-in test helper, no HTTP server needed
- `vi.fn()` / `vi.mocked()` — Vitest equivalents of Jest mocks
- Construct a fresh `Hono` app in `beforeEach` for isolation
- Test both success and error status codes
- Pass `method`, `headers`, `body` to `app.request()` for non-GET requests

---

## 2. Middleware Test

Testing custom middleware in isolation.

```typescript
import { describe, it, expect, vi } from 'vitest';
import { Hono } from 'hono';
import { authMiddleware } from '../middleware/auth';

describe('Auth Middleware', () => {
  const app = new Hono();

  const mockVerifyToken = vi.fn();

  app.use('/protected/*', authMiddleware({ verifyToken: mockVerifyToken }));
  app.get('/protected/data', (c) => c.json({ secret: 'value' }));

  it('should return 401 without Authorization header', async () => {
    const res = await app.request('/protected/data');
    expect(res.status).toBe(401);
  });

  it('should return 401 with invalid token', async () => {
    mockVerifyToken.mockResolvedValue(null);

    const res = await app.request('/protected/data', {
      headers: { Authorization: 'Bearer invalid-token' },
    });

    expect(res.status).toBe(401);
    expect(mockVerifyToken).toHaveBeenCalledWith('invalid-token');
  });

  it('should pass through with valid token', async () => {
    mockVerifyToken.mockResolvedValue({ userId: '1' });

    const res = await app.request('/protected/data', {
      headers: { Authorization: 'Bearer valid-token' },
    });

    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ secret: 'value' });
  });
});
```

**Key patterns:**
- Wire middleware + handler onto a test `Hono` app
- Mock the token verifier, not the middleware itself
- Test missing header, invalid token, and valid token paths
