# Authentication

## Overview

All projects use **Supabase** for authentication. Supabase provides managed auth with JWT tokens, multiple sign-in methods, and user management out of the box.

## Setup

### Environment Variables

```bash
# .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_JWT_SECRET=your-jwt-secret
```

### Install

```bash
npm install @supabase/supabase-js
```

## Backend Integration (Fastify)

### Auth Plugin

```javascript
// src/backend/plugins/auth.js
import fp from 'fastify-plugin';
import jwt from 'jsonwebtoken';

export default fp(async (app) => {
  // Decorator: authenticate request
  app.decorate('authenticate', async (req, reply) => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return reply.status(401).send({ success: false, error: 'No token provided' });
    }

    try {
      const payload = jwt.verify(token, process.env.SUPABASE_JWT_SECRET);
      req.user = payload;
      req.tenantId = payload.app_metadata?.tenant_id;
    } catch {
      return reply.status(401).send({ success: false, error: 'Invalid token' });
    }
  });

  // Decorator: require specific role
  app.decorate('requireRole', (role) => {
    return async (req, reply) => {
      await app.authenticate(req, reply);
      if (req.user?.app_metadata?.role !== role) {
        return reply.status(403).send({ success: false, error: 'Forbidden' });
      }
    };
  });
});
```

### Protecting Routes

```javascript
// In route definitions
export default async function protectedRoutes(app) {
  // All routes in this scope require auth
  app.addHook('onRequest', app.authenticate);

  app.get('/profile', {
    handler: async (req, reply) => {
      reply.send({ success: true, data: req.user });
    }
  });
}

// Admin-only route
app.get('/admin/users', {
  onRequest: app.requireRole('admin'),
  handler: async (req, reply) => {
    // Only admins reach here
  }
});
```

## Frontend Integration

### Supabase Client

```javascript
// services/auth.js
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL || window.__ENV__?.SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY || window.__ENV__?.SUPABASE_ANON_KEY
);

class AuthService {
  constructor() {
    this.user = null;
    this.session = null;
  }

  async init() {
    const { data } = await supabase.auth.getSession();
    this.session = data.session;
    this.user = data.session?.user;

    supabase.auth.onAuthStateChange((event, session) => {
      this.session = session;
      this.user = session?.user;
    });
  }

  async signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return data;
  }

  async signOut() {
    await supabase.auth.signOut();
    this.user = null;
    this.session = null;
  }

  getToken() {
    return this.session?.access_token;
  }

  get isAuthenticated() {
    return !!this.session;
  }
}

export const authService = new AuthService();
```

### API Client with Auth

```javascript
// services/api.js
import { authService } from './auth.js';

class ApiService {
  async request(method, path, body) {
    const headers = { 'Content-Type': 'application/json' };
    const token = authService.getToken();
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const response = await fetch(`/api${path}`, { method, headers, body: body ? JSON.stringify(body) : undefined });
    const data = await response.json();

    if (response.status === 401) {
      await authService.signOut();
      window.location.hash = '#/login';
      throw new Error('Session expired');
    }

    if (!data.success) throw new Error(data.error);
    return data.data;
  }

  get(path) { return this.request('GET', path); }
  post(path, body) { return this.request('POST', path, body); }
  put(path, body) { return this.request('PUT', path, body); }
  delete(path) { return this.request('DELETE', path); }
}

export const apiService = new ApiService();
```

## User Model

Supabase manages the `auth.users` table. Project-specific user data goes in a separate `users` table linked by Supabase user ID:

```javascript
// Migration
await knex.schema.createTable('users', (t) => {
  t.uuid('id').primary();  // Same as Supabase auth.users.id
  t.uuid('tenant_id').references('id').inTable('tenants');
  t.string('email').unique().notNullable();
  t.string('name').notNullable();
  t.string('role').defaultTo('user');
  t.timestamps(true, true);
});
```

## Roles

Standard roles across all projects:

| Role | Access |
|------|--------|
| `admin` | Full access, user management |
| `user` | Standard access, own data |

Additional roles can be defined per project (e.g. `coach`, `editor`).

Roles are stored in Supabase `app_metadata` and in the project's `users` table.
