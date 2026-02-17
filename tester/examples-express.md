# Express.js (Jest + Supertest) Examples

## 1. Route Test with Supertest

Testing Express routes using `supertest` — no running server needed.

```typescript
import request from 'supertest';
import express from 'express';
import { userRouter } from '../routes/users';
import { UserService } from '../services/userService';

jest.mock('../services/userService');

describe('User Routes', () => {
  let app: express.Application;
  const mockUserService = jest.mocked(new UserService());

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use('/users', userRouter);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /users/:id', () => {
    it('should return 200 with user data', async () => {
      const mockUser = { id: '1', name: 'Alice' };
      mockUserService.findById.mockResolvedValue(mockUser);

      const res = await request(app).get('/users/1');

      expect(res.status).toBe(200);
      expect(res.body).toEqual(mockUser);
      expect(mockUserService.findById).toHaveBeenCalledWith('1');
    });

    it('should return 404 when user not found', async () => {
      mockUserService.findById.mockResolvedValue(null);

      const res = await request(app).get('/users/999');

      expect(res.status).toBe(404);
      expect(res.body).toEqual({ error: 'User not found' });
    });
  });

  describe('POST /users', () => {
    it('should create user and return 201', async () => {
      const newUser = { name: 'Bob', email: 'bob@example.com' };
      const created = { id: '2', ...newUser };
      mockUserService.create.mockResolvedValue(created);

      const res = await request(app)
        .post('/users')
        .send(newUser)
        .set('Content-Type', 'application/json');

      expect(res.status).toBe(201);
      expect(res.body).toEqual(created);
    });

    it('should return 400 on validation error', async () => {
      const res = await request(app)
        .post('/users')
        .send({ name: '' })
        .set('Content-Type', 'application/json');

      expect(res.status).toBe(400);
      expect(res.body).toHaveProperty('errors');
    });
  });
});
```

**Key patterns:**
- `supertest` wraps Express app — no `app.listen()` required
- `jest.mock()` at module level for the service
- `jest.mocked()` for typed mock access
- Chain `.get()`, `.post()`, `.send()`, `.set()` for request building
- Assert `res.status` and `res.body`

---

## 2. Middleware Test

Testing middleware in isolation with mocked `req`, `res`, `next`.

```typescript
import { Request, Response, NextFunction } from 'express';
import { rateLimitMiddleware } from '../middleware/rateLimit';

describe('Rate Limit Middleware', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;
  let mockNext: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    mockReq = { ip: '127.0.0.1', headers: {} };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    mockNext = jest.fn();
  });

  it('should call next() when under rate limit', () => {
    rateLimitMiddleware(mockReq as Request, mockRes as Response, mockNext);

    expect(mockNext).toHaveBeenCalledTimes(1);
    expect(mockRes.status).not.toHaveBeenCalled();
  });

  it('should return 429 when rate limit exceeded', () => {
    // Simulate exceeding limit
    for (let i = 0; i < 100; i++) {
      rateLimitMiddleware(mockReq as Request, mockRes as Response, jest.fn());
    }

    rateLimitMiddleware(mockReq as Request, mockRes as Response, mockNext);

    expect(mockRes.status).toHaveBeenCalledWith(429);
    expect(mockRes.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: expect.stringContaining('rate limit') })
    );
    expect(mockNext).not.toHaveBeenCalled();
  });
});
```

**Key patterns:**
- Build `mockReq` / `mockRes` / `mockNext` manually — no HTTP needed
- `mockReturnThis()` to support method chaining (`res.status(429).json(...)`)
- Test both "allowed" and "blocked" paths
- `expect.objectContaining()` + `expect.stringContaining()` for flexible matching
