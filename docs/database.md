# Database Architecture

## Technology

- **PostgreSQL** — Production database for all projects
- **Knex.js** — Query builder and migration tool
- **No ORM** — Knex provides enough abstraction without the overhead

## Connection Setup

```javascript
// knexfile.js
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

```javascript
// src/backend/db/index.js
import knexLib from 'knex';
import knexConfig from '../../../knexfile.js';

const env = process.env.NODE_ENV || 'development';
export const db = knexLib(knexConfig[env]);
```

## Migrations

### Creating Migrations

```bash
npm run migrate:make -- create_users_table
```

### Migration Structure

Use a single consolidated migration for initial schema + seed data. Add incremental migrations for changes.

```javascript
// src/backend/db/migrations/20250101000000_initial_schema.js
export async function up(knex) {
  // Tenants
  await knex.schema.createTable('tenants', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.string('name').notNullable();
    t.jsonb('settings').defaultTo('{}');
    t.timestamps(true, true);
  });

  // Users
  await knex.schema.createTable('users', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    t.string('email').unique().notNullable();
    t.string('name').notNullable();
    t.string('role').defaultTo('user');
    t.timestamps(true, true);
  });

  // Seed data
  await knex('tenants').insert({
    id: '00000000-0000-0000-0001-000000000001',
    name: 'Default Organization'
  });
}

export async function down(knex) {
  await knex.schema.dropTableIfExists('users');
  await knex.schema.dropTableIfExists('tenants');
}
```

### Migration Commands

```bash
npm run migrate              # Run pending migrations
npm run migrate:make         # Create new migration file
npm run migrate:rollback     # Rollback last batch
npm run migrate:status       # Show migration status
```

### package.json scripts

```json
{
  "scripts": {
    "migrate": "knex migrate:latest",
    "migrate:make": "knex migrate:make",
    "migrate:rollback": "knex migrate:rollback",
    "migrate:status": "knex migrate:status"
  }
}
```

## Multi-Tenancy

All data is scoped by `tenant_id`. This is enforced at the service layer (see [backend.md](backend.md)).

### Rules

- Every data table has a `tenant_id` column (except global lookup tables)
- All queries filter by `tenant_id`
- The BaseService enforces this automatically
- Global/shared data tables (e.g. field types, categories) are explicitly marked and skip tenant filtering

### UUID Convention

Seeded/default data uses predictable UUID patterns for easy reference:

```
00000000-0000-0000-0001-xxx   Tenants
00000000-0000-0000-0002-xxx   Users
00000000-0000-0000-0003-xxx   Domain-specific type 1
00000000-0000-0000-0004-xxx   Domain-specific type 2
10000000-0000-0000-0000-xxx   Global data (no tenant scope)
```

## Common Table Patterns

### Standard Data Table

```javascript
await knex.schema.createTable('items', (t) => {
  t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
  t.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
  t.string('name').notNullable();
  t.string('status').defaultTo('active');
  t.jsonb('metadata').defaultTo('{}');
  t.timestamps(true, true);
});
```

### Key Conventions

- **Primary keys**: Always UUID, auto-generated
- **Foreign keys**: UUID with ON DELETE CASCADE
- **Timestamps**: `created_at` and `updated_at` on every table
- **Flexible data**: Use `jsonb` columns for dynamic/nested data
- **Status fields**: String enum, not boolean flags
- **Soft deletes**: Use `deleted_at` timestamp when needed, not hard deletes

## Indexes

```javascript
// Add indexes for frequently queried columns
await knex.schema.alterTable('items', (t) => {
  t.index('tenant_id');
  t.index('status');
  t.index(['tenant_id', 'status']);
  t.index('created_at');
});
```

Index guidelines:
- Always index `tenant_id` (it's in every query)
- Index foreign keys
- Index columns used in WHERE, ORDER BY, JOIN
- Composite index for common query patterns

## Transactions

```javascript
async transferItem(tenantId, itemId, newOwnerId) {
  return this.knex.transaction(async (trx) => {
    await trx('items')
      .where({ tenant_id: tenantId, id: itemId })
      .update({ owner_id: newOwnerId });

    await trx('audit_log').insert({
      tenant_id: tenantId,
      action: 'transfer',
      item_id: itemId,
      new_owner_id: newOwnerId
    });
  });
}
```

Use transactions for:
- Multi-table operations that must succeed or fail together
- Operations with audit logging
- Data integrity-critical operations

## Best Practices

### DO

- Use parameterized queries (Knex does this automatically)
- Create indexes for foreign keys and frequently queried columns
- Use transactions for multi-table operations
- Use `jsonb` for flexible/nested data
- Run migrations in CI/CD before deployment

### DON'T

- Store passwords as plain text (use Supabase auth or bcrypt)
- Use raw SQL string concatenation
- Use `SELECT *` in production queries — select specific columns
- Modify production database manually — always use migrations
- Skip the `tenant_id` filter
