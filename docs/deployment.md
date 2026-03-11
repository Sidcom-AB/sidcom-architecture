# Deployment

## Docker

All projects are deployed as Docker containers. Docker is used for **build and production**, not for local development.

### Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy source
COPY src/ ./src/
COPY knexfile.js ./

# Run migrations and start
EXPOSE 3000
CMD ["sh", "-c", "npm run migrate && node src/backend/server.js"]
```

### .dockerignore

```
node_modules/
.env
.env.local
.git/
.gitignore
*.md
docs/
input/
coverage/
.vscode/
.idea/
```

### Build and Run

```bash
# Build
npm run build
# or directly:
docker build -t my-project .

# Run
docker run -d \
  --name my-project \
  -p 3000:3000 \
  --env-file .env.production \
  my-project
```

### Docker Compose (with PostgreSQL)

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=db
      - DB_PORT=5432
      - DB_NAME=myproject
      - DB_USER=postgres
      - DB_PASSWORD=${DB_PASSWORD}
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
      - SUPABASE_JWT_SECRET=${SUPABASE_JWT_SECRET}
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myproject
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

## Workflow

### Development (no Docker)

```bash
npm run dev    # Node --watch, local PostgreSQL
```

### Build for production

```bash
npm run build  # Builds Docker image
```

### Deploy

```bash
docker compose up -d
```

## Environment Variables in Production

Never bake secrets into the Docker image. Pass them at runtime:

```bash
# Via env file
docker run --env-file .env.production my-project

# Via Docker Compose
# Reference .env or set in environment section
```

## Health Check

Add a health endpoint for container orchestration:

```javascript
app.get('/api/health', {
  schema: { hide: true },
  handler: async (req, reply) => {
    reply.send({ status: 'ok', timestamp: new Date().toISOString() });
  }
});
```
