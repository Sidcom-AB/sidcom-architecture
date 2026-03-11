# Sidcom Architecture

Shared architecture reference for all Sidcom projects. This repo defines conventions, patterns, and standards that every project must follow.

## Setup (New Project)

One step — copy `.claude/settings.json` into your project:

```bash
mkdir -p .claude
curl -o .claude/settings.json https://raw.githubusercontent.com/Sidcom-AB/sidcom-architecture/main/.claude/settings.json
```

That's it. Next time Claude Code starts in this project, the Setup hook will:

1. Add `.architecture/` as a git submodule (if missing)
2. Create `CLAUDE.md` from template (if missing)
3. Confirm everything is ready

## Setup (Cloning an Existing Project)

If someone clones a project that already has the submodule:

```bash
git clone --recurse-submodules git@github.com:Sidcom-AB/your-project.git
```

Or if Claude Code starts and the submodule is empty, the hook handles it automatically.

## Updating Architecture Docs

When this repo is updated, pull the latest in any project:

```bash
git submodule update --remote .architecture
git add .architecture
git commit -m "chore: update architecture docs"
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

- [CLAUDE.md](templates/CLAUDE.md) — Auto-copied by the Setup hook into new projects
