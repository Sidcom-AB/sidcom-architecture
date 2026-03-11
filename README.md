# Sidcom Architecture

Shared architecture reference for all Sidcom projects. This repo defines conventions, patterns, and standards that every project must follow.

## How to Use

### 1. Add as git submodule in your project

```bash
cd your-project
git submodule add git@github.com:Sidcom-AB/sidcom-architecture.git .architecture
```

This creates an `.architecture/` folder with all docs available locally.

### 2. Copy the template CLAUDE.md

```bash
cp .architecture/templates/CLAUDE.md ./CLAUDE.md
```

Edit the `PROJECT_NAME` and add any project-specific notes at the bottom.

### 3. Update architecture docs (all projects)

When architecture docs are updated in this repo, pull the latest in any project:

```bash
git submodule update --remote .architecture
git add .architecture
git commit -m "chore: update architecture docs"
```

### Cloning a project that uses this submodule

```bash
git clone --recurse-submodules git@github.com:Sidcom-AB/your-project.git

# Or if already cloned without submodules:
git submodule update --init
```

## Quick Reference

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

- [CLAUDE.md](templates/CLAUDE.md) — Drop-in CLAUDE.md for new projects (uses `.architecture/` submodule paths)
