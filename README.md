# Sidcom Architecture

Shared architecture reference for all Sidcom projects. This repo defines conventions, patterns, and standards that every project must follow.

## How to Use

### In a new project's CLAUDE.md

Point to this repo so Claude Code always has access to the architecture:

```markdown
## Architecture Reference

This project follows the Sidcom Architecture standard.
Before making architectural decisions, fetch the relevant docs:

- Overview: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/architecture.md
- Frontend: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/frontend.md
- Backend: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/backend.md
- Database: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/database.md
- Design System: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/design-system.md
- Auth: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/auth.md
- Security: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/security.md
- Coding Standards: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/coding-standards.md
- Git Workflow: https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/docs/git-workflow.md
```

### Quick Reference

| Decision | Standard |
|----------|----------|
| Runtime | Node.js 20+ |
| Modules | ES Modules (ESM) |
| Backend | Fastify + OpenAPI |
| Database | PostgreSQL + Knex |
| Frontend | Lit (Web Components) |
| Routing | Hash-based SPA (`/#/path`) |
| Styling | CSS custom properties (`--app-*`), shadcn-inspired |
| Auth | Supabase |
| Deploy | Docker |
| Language | JavaScript (no TypeScript) |
| Frameworks | None (no React/Vue/Angular) |

## Docs

| Document | Covers |
|----------|--------|
| [architecture.md](docs/architecture.md) | High-level principles, project structure, non-negotiable rules |
| [frontend.md](docs/frontend.md) | Lit components, SPA routing, view/controller pattern |
| [backend.md](docs/backend.md) | Fastify setup, route schemas, OpenAPI, service layer |
| [database.md](docs/database.md) | PostgreSQL + Knex, migrations, multi-tenancy |
| [design-system.md](docs/design-system.md) | CSS tokens, theming, dark/light mode |
| [auth.md](docs/auth.md) | Supabase auth integration |
| [security.md](docs/security.md) | Input validation, headers, CORS, secrets |
| [coding-standards.md](docs/coding-standards.md) | Naming, file structure, principles |
| [git-workflow.md](docs/git-workflow.md) | Branching, commits, PRs |
| [project-setup.md](docs/project-setup.md) | How to bootstrap a new project |
| [deployment.md](docs/deployment.md) | Docker build and deploy |

## Templates

- [CLAUDE.md](templates/CLAUDE.md) — Drop-in CLAUDE.md for new projects
