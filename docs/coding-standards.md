# Coding Standards

## Principles

**SOLID, DRY, KISS, YAGNI** — in that order of priority.

## Language

- **JavaScript only** — No TypeScript
- **ES Modules** — `import/export`, never `require/module.exports`
- **ES2022+** — Use modern syntax (optional chaining, nullish coalescing, top-level await)
- **`async/await`** — Never callbacks

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Files | `kebab-case` | `user-service.js` |
| Folders | `kebab-case` | `app-dialog/` |
| Classes | `PascalCase` | `UserService` |
| Functions/methods | `camelCase` | `findById()` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRIES` |
| Private members | `_prefix` | `_internalState` |
| Custom elements | `kebab-case` with prefix | `<app-dialog>` |
| CSS variables | `--app-*` | `--app-primary` |
| Env variables | `UPPER_SNAKE_CASE` | `DB_HOST` |

## File Organization

### Import Order

```javascript
// 1. Node built-ins
import path from 'path';
import { fileURLToPath } from 'url';

// 2. External packages
import Fastify from 'fastify';
import { LitElement, html, css } from 'lit';

// 3. Internal modules (absolute)
import { UserService } from '../services/user-service.js';

// 4. Relative imports
import { styles } from './my-component.styles.js';
```

### File Size Limits

| Metric | Limit |
|--------|-------|
| Function body | ~30 lines |
| File | ~300 lines |
| Nesting depth | 3 levels max |

If a file or function grows beyond these limits, refactor.

## Module Pattern

```javascript
// Export classes and functions, not default objects
export class UserService { }
export function formatDate(date) { }

// Singletons: export instance
class ApiService { }
export const apiService = new ApiService();
```

## Error Handling

```javascript
// Specific error handling
try {
  const user = await userService.findById(id);
} catch (error) {
  if (error instanceof NotFoundError) {
    // Handle specifically
  }
  throw error; // Re-throw unknown errors
}

// Never swallow errors silently
try { } catch { } // WRONG
```

## Comments

```javascript
// Explain WHY, not WHAT
// Rate-limit login attempts to prevent brute force attacks
app.post('/login', rateLimit(5), handler);

// Don't state the obvious
// Get user by id  ← WRONG, the function name says this
async function getUserById(id) { }
```

## Forbidden Patterns

- `console.log` in production code (use `console.warn`/`console.error` or a logger)
- Commented-out code — delete it, git has history
- TODO without context — `// TODO(name): reason` if you must
- Magic numbers — use named constants
- Deep nesting (>3 levels) — extract functions
- Mixed concerns — UI in services, business logic in views
- `var` — always `const`, use `let` only when reassignment is needed

## package.json

```json
{
  "type": "module",
  "engines": {
    "node": ">=20.0.0"
  },
  "scripts": {
    "dev": "knex migrate:latest && node --watch src/backend/server.js",
    "start": "knex migrate:latest && node src/backend/server.js",
    "migrate": "knex migrate:latest",
    "migrate:make": "knex migrate:make",
    "migrate:rollback": "knex migrate:rollback",
    "build": "npm run build:docker",
    "build:docker": "docker build -t project-name ."
  }
}
```

## Development Workflow

- **`npm run dev`** for development — runs migrations first, then starts Node with `--watch` for auto-reload
- **`npm start`** for production — runs migrations first, then starts the server
- Never kill/restart the dev server to test changes — `--watch` handles it
- AI assistants: edit files only, never start servers
- User starts the server, AI edits code

## Allowed Commands (for AI assistants)

```
npm run lint
npm run test
npm run build
```

## Forbidden Commands (for AI assistants)

```
npm start
npm run dev
node server.js
```

The user manages server lifecycle. AI makes code changes only.
