# Security

## Secrets Management

### Never commit secrets

```bash
# .env (gitignored)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-key
SUPABASE_JWT_SECRET=your-secret
DB_PASSWORD=your-password
```

```bash
# .env.example (committed — template without real values)
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_JWT_SECRET=
DB_PASSWORD=
```

### Rules

- `.env` must be in `.gitignore`
- Never hardcode secrets in source code
- Use `.env.example` as a template
- Rotate secrets if accidentally committed

## Input Validation

### Fastify Schema Validation

Fastify validates all input automatically when schemas are defined (see [backend.md](backend.md)). This is the first line of defense.

### SQL Injection Prevention

Knex uses parameterized queries by default:

```javascript
// SAFE — Knex handles parameterization
await knex('users').where({ email }).first();
await knex('users').where('id', '=', userId).first();

// DANGEROUS — never do this
await knex.raw(`SELECT * FROM users WHERE email = '${email}'`);
```

### XSS Prevention

Lit's `html` tagged template literal auto-escapes values:

```javascript
// SAFE — Lit escapes automatically
render() {
  return html`<p>${this.userInput}</p>`;
}

// DANGEROUS — bypasses escaping
this.innerHTML = userInput;
```

If you must use raw HTML (rare), sanitize first.

## Security Headers

```javascript
// src/backend/plugins/security.js
import fp from 'fastify-plugin';
import helmet from '@fastify/helmet';

export default fp(async (app) => {
  await app.register(helmet, {
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"]
      }
    }
  });
});
```

## CORS

```javascript
await app.register(fastifyCors, {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true
});
```

## Rate Limiting

```javascript
import rateLimit from '@fastify/rate-limit';

await app.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute'
});

// Stricter limits for auth endpoints
app.post('/api/auth/login', {
  config: { rateLimit: { max: 5, timeWindow: '1 minute' } },
  handler: loginHandler
});
```

## File Uploads

```javascript
import multipart from '@fastify/multipart';

await app.register(multipart, {
  limits: {
    fileSize: 5 * 1024 * 1024  // 5MB
  }
});

// Validate file type in handler
app.post('/api/upload', async (req, reply) => {
  const file = await req.file();
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];

  if (!allowedTypes.includes(file.mimetype)) {
    return reply.status(400).send({ success: false, error: 'Invalid file type' });
  }

  // Process file...
});
```

## Error Handling

Never expose internal details in production:

```javascript
app.setErrorHandler((error, req, reply) => {
  app.log.error(error);

  const message = process.env.NODE_ENV === 'production'
    ? 'Internal server error'
    : error.message;

  reply.status(error.statusCode || 500).send({
    success: false,
    error: message
  });
});
```

## Security Checklist

Before deployment:

- [ ] All secrets in `.env`, not in code
- [ ] `.env` in `.gitignore`
- [ ] Fastify schemas validate all input
- [ ] Knex used for all queries (no raw string SQL)
- [ ] Rate limiting on auth endpoints
- [ ] Security headers configured
- [ ] CORS restricted to known origins
- [ ] File uploads validated (type, size)
- [ ] Error messages generic in production
- [ ] No `console.log` with sensitive data
- [ ] HTTPS enforced in production
- [ ] Dependencies up to date
