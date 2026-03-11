# PROJECT_NAME

## Architecture

This project follows the **Sidcom Architecture** standard.

Reference docs (fetch when needed):
- https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/architecture.md
- https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/frontend.md
- https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/backend.md
- https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/database.md
- https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/design-system.md
- https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/auth.md
- https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/security.md
- https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/coding-standards.md

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
