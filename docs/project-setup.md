# Project Setup

How to bootstrap a new project following the Sidcom Architecture.

## 1. Initialize

```bash
mkdir my-project && cd my-project
git init
npm init -y
npm pkg set type=module
npm pkg set engines.node=">=20.0.0"
```

## 2. Create Directory Structure

```bash
# Backend
mkdir -p src/backend/{routes,services,plugins,db/migrations}

# Frontend
mkdir -p src/frontend/{app,views,components/ui,services,styles}

# Shared
mkdir -p src/assets
```

## 3. Install Dependencies

```bash
# Backend
npm install fastify @fastify/static @fastify/cors @fastify/swagger @fastify/swagger-ui @fastify/helmet @fastify/rate-limit
npm install knex pg dotenv

# Frontend (Lit)
npm install lit

# Auth
npm install @supabase/supabase-js jsonwebtoken

# Dev
npm install -D fastify-plugin
```

## 4. Configure Files

### package.json scripts

```json
{
  "scripts": {
    "dev": "knex migrate:latest && node --watch src/backend/server.js",
    "start": "knex migrate:latest && node src/backend/server.js",
    "migrate": "knex migrate:latest",
    "migrate:make": "knex migrate:make",
    "migrate:rollback": "knex migrate:rollback",
    "build": "docker build -t my-project ."
  }
}
```

### .env.example

```bash
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=my_project
DB_USER=postgres
DB_PASSWORD=

SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_JWT_SECRET=
```

### .gitignore

```gitignore
node_modules/
.env
.env.local
*.log
dist/
.DS_Store
Thumbs.db
.vscode/
.idea/
coverage/
```

### knexfile.js

```javascript
import dotenv from 'dotenv';
dotenv.config();

export default {
  development: {
    client: 'postgresql',
    connection: {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME,
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD
    },
    migrations: {
      directory: './src/backend/db/migrations'
    }
  },
  production: {
    client: 'postgresql',
    connection: process.env.DATABASE_URL,
    pool: { min: 2, max: 10 },
    migrations: {
      directory: './src/backend/db/migrations'
    }
  }
};
```

## 5. Copy CLAUDE.md

Copy [templates/CLAUDE.md](../templates/CLAUDE.md) into your project root and adjust the project name.

## 6. Copy .mcp.json (optional)

If using MCP tools (Playwright, etc.), copy [templates/.mcp.json](../templates/.mcp.json).

## 7. Create Initial Migration

```bash
npm run migrate:make -- initial_schema
```

Edit the migration following the patterns in [database.md](database.md).

## 8. Start Building

```bash
cp .env.example .env  # Fill in real values
npm run migrate       # Set up database
npm run dev           # Start developing
```

## Checklist

- [ ] `package.json` has `"type": "module"`
- [ ] Directory structure follows convention
- [ ] `.env` exists and is in `.gitignore`
- [ ] `CLAUDE.md` is in project root
- [ ] `knexfile.js` configured
- [ ] Initial migration created
- [ ] Fastify server entry point at `src/backend/server.js`
- [ ] Frontend entry at `src/frontend/index.html`
