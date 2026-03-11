# Git Workflow

## Branch Strategy

```
main (production)
│
├── develop (staging, optional)
│   ├── feature/user-auth
│   ├── bugfix/login-error
│   └── refactor/api-structure
│
└── hotfix/critical-fix
```

### Branch Naming

```
feature/short-description
bugfix/what-is-broken
hotfix/urgent-fix
refactor/what-is-improved
```

## Commit Messages

### Format

```
type: short description

Optional longer body explaining why.
```

### Types

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code restructuring (no behavior change) |
| `style` | Formatting (no logic change) |
| `test` | Adding/updating tests |
| `chore` | Maintenance, deps, configs |
| `perf` | Performance improvement |

### Examples

```bash
# Good
git commit -m "feat: add user profile settings page"
git commit -m "fix: prevent duplicate form submission"
git commit -m "refactor: extract validation to shared service"

# Bad
git commit -m "fixed stuff"
git commit -m "WIP"
git commit -m "updates"
```

### Rules

- Imperative mood: "add feature" not "added feature"
- Lowercase first word after type
- No period at the end
- Keep subject under 72 characters
- One logical change per commit

## Pull Requests

### Title Format

```
feat: add user profile page
fix: resolve login timeout
```

### PR Body Template

```markdown
## Summary
- Brief description of changes

## Type
- [ ] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation

## Checklist
- [ ] Follows project coding standards
- [ ] No hardcoded values or secrets
- [ ] Tested manually
- [ ] Documentation updated if needed
```

## .gitignore

```gitignore
# Dependencies
node_modules/

# Environment
.env
.env.local
.env.*.local

# Database
*.db
*.sqlite

# Logs
*.log
npm-debug.log*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Build
dist/
build/

# Uploads
uploads/

# Coverage
coverage/
```

## Rules

### DO

- Commit frequently with clear messages
- Pull before pushing
- Keep commits atomic (one change per commit)
- Review your own diff before creating PR

### DON'T

- Commit directly to main
- Force push to shared branches
- Commit secrets, `.env`, or large binary files
- Leave commented-out code
- Mix feature changes with formatting changes
