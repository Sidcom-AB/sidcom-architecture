# Backend Architecture

## Overview

All backends use Fastify with JSON Schema validation, automatic OpenAPI documentation, and a service layer for business logic.

## Fastify Setup

```javascript
// src/backend/server.js
import Fastify from 'fastify';
import fastifyStatic from '@fastify/static';
import fastifySwagger from '@fastify/swagger';
import fastifySwaggerUi from '@fastify/swagger-ui';
import fastifyCors from '@fastify/cors';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const app = Fastify({ logger: true });

// Plugins
await app.register(fastifyCors, {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true
});

await app.register(fastifySwagger, {
  openapi: {
    info: {
      title: 'Project API',
      version: '1.0.0'
    }
  }
});

await app.register(fastifySwaggerUi, { routePrefix: '/docs' });

// API routes
await app.register(import('./routes/index.js'), { prefix: '/api' });

// Static: shared assets
await app.register(fastifyStatic, {
  root: path.join(__dirname, '../assets'),
  prefix: '/assets/',
  decorateReply: false
});

// Static: frontend SPA
await app.register(fastifyStatic, {
  root: path.join(__dirname, '../frontend'),
  prefix: '/',
  decorateReply: false
});

// SPA fallback — serve index.html for all non-API, non-asset routes
app.setNotFoundHandler((req, reply) => {
  if (req.url.startsWith('/api/')) {
    reply.status(404).send({ success: false, error: 'Route not found' });
  } else {
    reply.sendFile('index.html', path.join(__dirname, '../frontend'));
  }
});

const start = async () => {
  const port = process.env.PORT || 3000;
  await app.listen({ port, host: '0.0.0.0' });
  console.log(`Server running on http://localhost:${port}`);
  console.log(`API docs at http://localhost:${port}/docs`);
};

start();
```

## Route Definitions

Every route defines a JSON Schema. This gives you:
- **Automatic request validation** (Fastify rejects invalid input)
- **Automatic OpenAPI documentation** (visible at `/docs`)
- **Response serialization** (only declared fields are sent)

### Route Pattern

```javascript
// src/backend/routes/users.js
import { UserService } from '../services/user-service.js';

const userSchemas = {
  user: {
    type: 'object',
    properties: {
      id: { type: 'string', format: 'uuid' },
      email: { type: 'string', format: 'email' },
      name: { type: 'string' },
      role: { type: 'string', enum: ['admin', 'user'] },
      created_at: { type: 'string', format: 'date-time' }
    }
  }
};

export default async function userRoutes(app) {
  const service = new UserService(app.knex);

  // List all
  app.get('/', {
    schema: {
      tags: ['Users'],
      summary: 'List all users',
      response: {
        200: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            data: { type: 'array', items: userSchemas.user }
          }
        }
      }
    },
    handler: async (req, reply) => {
      const users = await service.findAll(req.tenantId);
      reply.send({ success: true, data: users });
    }
  });

  // Get one
  app.get('/:id', {
    schema: {
      tags: ['Users'],
      summary: 'Get user by ID',
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' }
        },
        required: ['id']
      },
      response: {
        200: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            data: userSchemas.user
          }
        }
      }
    },
    handler: async (req, reply) => {
      const user = await service.findById(req.tenantId, req.params.id);
      if (!user) {
        return reply.status(404).send({ success: false, error: 'User not found' });
      }
      reply.send({ success: true, data: user });
    }
  });

  // Create
  app.post('/', {
    schema: {
      tags: ['Users'],
      summary: 'Create user',
      body: {
        type: 'object',
        properties: {
          email: { type: 'string', format: 'email' },
          name: { type: 'string', minLength: 1 }
        },
        required: ['email', 'name']
      },
      response: {
        201: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            data: userSchemas.user
          }
        }
      }
    },
    handler: async (req, reply) => {
      const user = await service.create(req.tenantId, req.body);
      reply.status(201).send({ success: true, data: user });
    }
  });

  // Update
  app.put('/:id', {
    schema: {
      tags: ['Users'],
      summary: 'Update user',
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' }
        },
        required: ['id']
      },
      body: {
        type: 'object',
        properties: {
          email: { type: 'string', format: 'email' },
          name: { type: 'string' }
        }
      },
      response: {
        200: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            data: userSchemas.user
          }
        }
      }
    },
    handler: async (req, reply) => {
      const user = await service.update(req.tenantId, req.params.id, req.body);
      reply.send({ success: true, data: user });
    }
  });

  // Delete
  app.delete('/:id', {
    schema: {
      tags: ['Users'],
      summary: 'Delete user',
      params: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' }
        },
        required: ['id']
      },
      response: {
        200: {
          type: 'object',
          properties: {
            success: { type: 'boolean' }
          }
        }
      }
    },
    handler: async (req, reply) => {
      await service.delete(req.tenantId, req.params.id);
      reply.send({ success: true });
    }
  });
}
```

## REST Conventions

### URL Structure

```
GET    /api/resources           List all
GET    /api/resources/:id       Get one
POST   /api/resources           Create
PUT    /api/resources/:id       Update (full replace)
PATCH  /api/resources/:id       Update (partial)
DELETE /api/resources/:id       Delete
```

### Response Format

Every response follows this structure:

```json
// Success
{
  "success": true,
  "data": { }
}

// Success with list
{
  "success": true,
  "data": [ ],
  "meta": { "total": 100, "page": 1, "pageSize": 20 }
}

// Error
{
  "success": false,
  "error": "Human-readable error message"
}
```

### Status Codes

| Code | When |
|------|------|
| 200 | Success (GET, PUT, PATCH, DELETE) |
| 201 | Created (POST) |
| 400 | Bad request / validation error |
| 401 | Unauthorized (no/invalid token) |
| 403 | Forbidden (insufficient role) |
| 404 | Resource not found |
| 429 | Rate limited |
| 500 | Server error |

## Service Layer

Services contain all business logic. Routes call services, services call Knex.

```
Route (schema + handler) → Service (logic) → Knex (database)
```

### Base Service

```javascript
// src/backend/services/base-service.js
export class BaseService {
  constructor(knex) {
    this.knex = knex;
  }

  // Generic CRUD with tenant scoping
  async findAll(tenantId, table) {
    return this.knex(table).where({ tenant_id: tenantId });
  }

  async findById(tenantId, table, id) {
    return this.knex(table).where({ tenant_id: tenantId, id }).first();
  }

  async create(tenantId, table, data) {
    const [record] = await this.knex(table)
      .insert({ ...data, tenant_id: tenantId })
      .returning('*');
    return record;
  }

  async update(tenantId, table, id, data) {
    const [record] = await this.knex(table)
      .where({ tenant_id: tenantId, id })
      .update({ ...data, updated_at: this.knex.fn.now() })
      .returning('*');
    return record;
  }

  async delete(tenantId, table, id) {
    return this.knex(table)
      .where({ tenant_id: tenantId, id })
      .del();
  }
}
```

### Concrete Service

```javascript
// src/backend/services/user-service.js
import { BaseService } from './base-service.js';

export class UserService extends BaseService {
  constructor(knex) {
    super(knex);
    this.table = 'users';
  }

  async findAll(tenantId) {
    return super.findAll(tenantId, this.table);
  }

  async findById(tenantId, id) {
    return super.findById(tenantId, this.table, id);
  }

  async create(tenantId, data) {
    // Business logic: validate email uniqueness, etc.
    const existing = await this.knex(this.table)
      .where({ email: data.email })
      .first();
    if (existing) throw new Error('Email already exists');

    return super.create(tenantId, this.table, data);
  }

  async update(tenantId, id, data) {
    return super.update(tenantId, this.table, id, data);
  }

  async delete(tenantId, id) {
    return super.delete(tenantId, this.table, id);
  }
}
```

## Fastify Plugins

### Knex Plugin

```javascript
// src/backend/plugins/knex.js
import fp from 'fastify-plugin';
import knexLib from 'knex';
import knexConfig from '../../../knexfile.js';

export default fp(async (app) => {
  const knex = knexLib(knexConfig[process.env.NODE_ENV || 'development']);
  app.decorate('knex', knex);
  app.addHook('onClose', () => knex.destroy());
});
```

### Auth Plugin

See [auth.md](auth.md) for Supabase integration.

## Error Handling

### Global Error Handler

```javascript
app.setErrorHandler((error, req, reply) => {
  app.log.error(error);

  const status = error.statusCode || 500;
  const message = status === 500 && process.env.NODE_ENV === 'production'
    ? 'Internal server error'
    : error.message;

  reply.status(status).send({ success: false, error: message });
});
```

### Custom Errors

```javascript
// src/backend/errors.js
export class AppError extends Error {
  constructor(message, statusCode = 400) {
    super(message);
    this.statusCode = statusCode;
  }
}

export class NotFoundError extends AppError {
  constructor(resource = 'Resource') {
    super(`${resource} not found`, 404);
  }
}

export class ForbiddenError extends AppError {
  constructor() {
    super('Forbidden', 403);
  }
}
```

## Real-Time Communication (WebSocket)

All real-time features use **WebSocket** with an event-bus pattern. Never use HTTP polling, long-polling, or Server-Sent Events (SSE).

### Why WebSocket

- Bidirectional: server can push events to clients
- Low latency: persistent connection, no HTTP overhead per message
- Event-driven: aligns with our architectural pattern of reactive updates
- One connection per client: simple multiplexing via event types

### WebSocket Setup

Use the `ws` library with Fastify's `noServer` mode for manual upgrade routing:

```javascript
// src/backend/plugins/websocket.js
import { WebSocketServer } from 'ws';

const wss = new WebSocketServer({ noServer: true });

// Handle upgrade in server.js
app.server.on('upgrade', (req, socket, head) => {
  const { pathname } = new URL(req.url, 'http://localhost');
  if (pathname === '/ws') {
    wss.handleUpgrade(req, socket, head, (ws) => {
      wss.emit('connection', ws, req);
    });
  }
});
```

### Event Protocol

All messages are JSON with an `event` field:

```javascript
// Server → Client
{ "event": "resource:updated", "data": { ... } }
{ "event": "slide:updated", "section": 0, "slide": 1, "data": { ... } }

// Client → Server
{ "event": "subscribe", "id": "resource-uuid" }
{ "event": "capture:response", "requestId": "...", "dataUrl": "..." }
```

### Rules

- **WebSocket only** — no SSE, no HTTP long-polling, no short-polling
- **Event-bus pattern** — clients subscribe by resource ID, server broadcasts to relevant clients
- **JSON protocol** — all messages are `JSON.stringify`/`JSON.parse`
- **Scoped connections** — each WebSocket connection is scoped to a resource (e.g. presentation ID via `?id=UUID`)
- **Multiple paths** — use separate WebSocket paths for different concerns (e.g. `/ws` for data, `/ws/agent` for AI)
- **Graceful degradation** — app should work (read-only) if WebSocket fails to connect

## IMPORTANT: Fastify Response Schema

Fastify validates responses against the schema. **Fields not declared in the response schema are silently removed.** Always ensure every returned field is listed in the schema.
