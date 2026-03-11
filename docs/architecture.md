# Architecture

## Core Principles

- **Vanilla JavaScript** — ES Modules, no TypeScript, no transpilation
- **No frameworks** — No React, Vue, Angular. Lit for components, Fastify for backend
- **Separation of concerns** — Views compose, controllers orchestrate, services do work
- **Reuse over duplication** — If it appears twice, it becomes a component
- **Simple over clever** — Predictable, explicit, slightly boring. That's a feature
- **Long-term maintainability** — Designed for 5-10 year lifespan

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| Runtime | Node.js 20+ | LTS, ESM support |
| Backend | Fastify | OpenAPI/Swagger built-in, schema validation, fast |
| Database | PostgreSQL + Knex | Reliable, migrations, query builder |
| Frontend | Lit (Web Components) | Small (~5KB), reactive, standard-based |
| Routing | Hash-based SPA | Deep linking, refresh-safe, no server rewrites |
| Styling | CSS custom properties | No preprocessors, themeable |
| Auth | Supabase | Managed auth, JWT |
| Deploy | Docker | Consistent environments |

## High-Level Architecture

```
Browser (SPA)
├── Router (hash-based)
├── Views (Lit components, one per route)
├── Controllers (plain JS classes)
├── Services (API calls, state)
└── UI Components (reusable Lit components)

Fastify Server
├── Routes (JSON Schema → OpenAPI)
├── Services (business logic)
├── Knex (database queries)
└── Static file serving (SPA + assets)
```

## Application Flow

```
Router → View → Controller → Service → API
                    ↓
            UI Components (Lit)
```

- **Router** maps URL hash to a View
- **View** is a Lit component representing a full page. Composes UI components. Has one Controller.
- **Controller** is a plain JS class. Handles interactions, calls services, provides data to the view. No DOM manipulation.
- **Service** encapsulates I/O (API, storage, auth). Reusable across views.
- **UI Components** are reusable Lit elements in `components/ui/`.

## Project Structure

```
project-root/
├── src/
│   ├── backend/
│   │   ├── server.js              # Fastify entry point
│   │   ├── routes/                # Route definitions (with JSON schemas)
│   │   ├── services/              # Business logic
│   │   ├── plugins/               # Fastify plugins (auth, cors, swagger)
│   │   └── db/
│   │       ├── index.js           # Knex connection
│   │       └── migrations/        # Knex migration files
│   │
│   ├── frontend/
│   │   ├── index.html             # SPA entry point
│   │   ├── app/
│   │   │   ├── app.js             # Application bootstrap
│   │   │   └── router.js          # Hash-based router config
│   │   ├── views/                 # One folder per route/page
│   │   │   └── settings/
│   │   │       ├── settings-view.js
│   │   │       └── settings-controller.js
│   │   ├── components/
│   │   │   └── ui/                # Reusable Lit components
│   │   │       └── app-dialog/
│   │   │           ├── app-dialog.js
│   │   │           └── app-dialog.styles.js
│   │   ├── services/              # Frontend services
│   │   │   ├── api.js             # Backend API client
│   │   │   └── auth.js            # Auth state
│   │   └── styles/
│   │       ├── tokens.css         # Design tokens
│   │       ├── theme-dark.css     # Dark theme
│   │       ├── theme-light.css    # Light theme
│   │       └── reset.css          # CSS reset
│   │
│   └── assets/                    # Shared images, fonts
│
├── package.json
├── knexfile.js
├── Dockerfile
├── .env.example
├── CLAUDE.md
└── .mcp.json
```

## Single Server

One Fastify instance serves everything:

```
http://localhost:3000/           → Frontend SPA (static)
http://localhost:3000/api/*      → Backend API (JSON)
http://localhost:3000/assets/*   → Shared assets
http://localhost:3000/docs       → Swagger/OpenAPI documentation
```

Why single server:
- Simplified deployment (one Docker container)
- Shared authentication context
- No CORS complexity in production
- Single port for development

## Non-Negotiable Rules

1. **No duplicated UI** — If a pattern appears twice, extract to `components/ui/`
2. **No logic in views** — Views compose and delegate, controllers handle logic
3. **No hardcoded colors/values** — Use CSS custom properties (`--app-*`)
4. **No direct database access from routes** — Always go through a service
5. **No framework lock-in** — Lit + Fastify, nothing more
6. **Multi-tenant aware** — All queries scoped by tenant context
7. **Schema-first API** — Every Fastify route defines its JSON Schema
