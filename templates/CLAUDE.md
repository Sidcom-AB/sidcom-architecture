# PROJECT_NAME

## Architecture

This project follows the **Sidcom Architecture** standard.

### Setup

If the `.architecture/` directory does not exist in this repo, run:

```bash
git submodule add git@github.com:Sidcom-AB/sidcom-architecture.git .architecture
```

If it exists but is empty, run:

```bash
git submodule update --init
```

### Reference Docs

Read these BEFORE making any architectural decisions:

- [Architecture & Principles](.architecture/docs/architecture.md)
- [Frontend (Lit, Routing, Components)](.architecture/docs/frontend.md)
- [Backend (Fastify, OpenAPI, Services)](.architecture/docs/backend.md)
- [Database (PostgreSQL, Knex)](.architecture/docs/database.md)
- [Design System (CSS Tokens, Theming)](.architecture/docs/design-system.md)
- [Auth (Supabase)](.architecture/docs/auth.md)
- [Security](.architecture/docs/security.md)
- [Coding Standards](.architecture/docs/coding-standards.md)
- [Git Workflow](.architecture/docs/git-workflow.md)
- [Project Setup](.architecture/docs/project-setup.md)
- [Deployment (Docker)](.architecture/docs/deployment.md)

**NEVER add architectural decisions to this file.** Architecture lives in `.architecture/` (shared repo). This file is only for project-specific configuration.

## Quick Reference

| Layer | Technology |
|-------|-----------|
| Backend | Fastify + OpenAPI |
| Database | PostgreSQL + Knex |
| Frontend | Lit (Web Components) |
| Routing | Hash-based SPA |
| Styling | CSS custom properties (`--app-*`) |
| Auth | Supabase |

## Rules

- Vanilla JavaScript, ES Modules, no TypeScript
- Lit components in `components/ui/` — never duplicate UI
- View → Controller → Service — no logic in views
- CSS variables only — no hardcoded colors
- Fastify JSON Schema on every route
- Multi-tenant: all queries scoped by tenant
- `npm run dev` uses `--watch` — never restart manually

## Development

```bash
npm run dev              # Dev server with --watch
npm run migrate          # Run database migrations
npm run migrate:make     # Create new migration
npm run build            # Docker build
```

## Workflow

- User starts the server
- AI edits code only, never starts/stops servers
- Allowed: `npm run lint`, `npm run test`, `npm run build`
- Forbidden: `npm start`, `npm run dev`, `node server.js`

## Project-Specific Notes

<!-- Add project-specific config here (ports, env vars, special setup, etc.) -->
