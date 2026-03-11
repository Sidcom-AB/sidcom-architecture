# Design System

## Philosophy

shadcn-inspired approach: CSS custom properties with HSL values, semantic tokens, dark/light themes. No UI framework dependency — components are styled via tokens.

## File Structure

```
styles/
├── reset.css           # CSS reset / normalization
├── tokens.css          # Design tokens (spacing, typography, radii, z-index)
├── theme-dark.css      # Dark theme color definitions
├── theme-light.css     # Light theme color definitions
└── app.css             # Global layout and utility styles
```

## Color System (HSL)

Colors use raw HSL values (without the `hsl()` wrapper) for flexibility — this enables opacity adjustments with the `/` syntax.

### Theme Variables

```css
/* theme-dark.css */
[data-theme="dark"] {
  --app-background:      222 47% 5%;
  --app-background-alt:  220 40% 9%;
  --app-card:            220 35% 13%;
  --app-card-hover:      220 32% 17%;
  --app-foreground:      210 40% 93%;
  --app-foreground-muted: 215 20% 58%;
  --app-border:          217 30% 21%;
  --app-primary:         212 92% 67%;
  --app-success:         142 71% 45%;
  --app-warning:         38 92% 50%;
  --app-destructive:     0 72% 63%;
}

/* theme-light.css */
[data-theme="light"] {
  --app-background:      0 0% 100%;
  --app-background-alt:  220 14% 96%;
  --app-card:            0 0% 100%;
  --app-card-hover:      220 14% 96%;
  --app-foreground:      222 47% 11%;
  --app-foreground-muted: 215 16% 47%;
  --app-border:          214 32% 91%;
  --app-primary:         212 92% 45%;
  --app-success:         142 71% 35%;
  --app-warning:         38 92% 45%;
  --app-destructive:     0 72% 51%;
}
```

### Semantic Aliases

```css
/* tokens.css */
:root {
  --background:       hsl(var(--app-background));
  --background-alt:   hsl(var(--app-background-alt));
  --card:             hsl(var(--app-card));
  --foreground:       hsl(var(--app-foreground));
  --muted:            hsl(var(--app-foreground-muted));
  --border:           hsl(var(--app-border));
  --primary:          hsl(var(--app-primary));
  --success:          hsl(var(--app-success));
  --warning:          hsl(var(--app-warning));
  --destructive:      hsl(var(--app-destructive));
}
```

### Using Colors

```css
/* Always use semantic variables */
.card {
  background: var(--card);
  border: 1px solid var(--border);
  color: var(--foreground);
}

/* Opacity via HSL slash syntax */
.overlay {
  background: hsl(var(--app-background) / 0.8);
}

/* Never hardcode colors */
.bad { background: #1a1a2e; }    /* WRONG */
.good { background: var(--card); } /* CORRECT */
```

## Spacing Scale (4px base)

```css
:root {
  --app-space-1:   0.25rem;   /*  4px */
  --app-space-2:   0.5rem;    /*  8px */
  --app-space-3:   0.75rem;   /* 12px */
  --app-space-4:   1rem;      /* 16px */
  --app-space-6:   1.5rem;    /* 24px */
  --app-space-8:   2rem;      /* 32px */
  --app-space-12:  3rem;      /* 48px */
  --app-space-16:  4rem;      /* 64px */
}
```

## Typography

```css
:root {
  --app-font-sans:     'Inter', system-ui, -apple-system, sans-serif;
  --app-font-mono:     'JetBrains Mono', 'Fira Code', monospace;

  --app-text-xs:       0.75rem;    /* 12px */
  --app-text-sm:       0.875rem;   /* 14px */
  --app-text-base:     1rem;       /* 16px */
  --app-text-lg:       1.125rem;   /* 18px */
  --app-text-xl:       1.25rem;    /* 20px */
  --app-text-2xl:      1.5rem;     /* 24px */

  --app-font-normal:   400;
  --app-font-medium:   500;
  --app-font-semibold: 600;
  --app-font-bold:     700;

  --app-leading-tight: 1.25;
  --app-leading-normal: 1.5;
}
```

## Border Radius

```css
:root {
  --app-radius-sm:     0.25rem;    /*  4px */
  --app-radius-md:     0.375rem;   /*  6px — default */
  --app-radius-lg:     0.5rem;     /*  8px */
  --app-radius-xl:     0.75rem;    /* 12px */
  --app-radius-full:   9999px;     /* pill shape */
}
```

## Shadows

```css
:root {
  --app-shadow-sm:     0 1px 2px hsl(var(--app-background) / 0.05);
  --app-shadow-md:     0 4px 6px hsl(var(--app-background) / 0.1);
  --app-shadow-lg:     0 10px 15px hsl(var(--app-background) / 0.15);
}
```

## Z-Index Scale

```css
:root {
  --app-z-dropdown:    50;
  --app-z-sticky:      100;
  --app-z-overlay:     200;
  --app-z-modal:       300;
  --app-z-toast:       400;
}
```

## Theme Switching

Theme is controlled via `data-theme` attribute on `<html>`:

```javascript
// services/theme.js
class ThemeService {
  constructor() {
    this.theme = localStorage.getItem('theme') || 'dark';
    document.documentElement.setAttribute('data-theme', this.theme);
  }

  toggle() {
    this.theme = this.theme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', this.theme);
    localStorage.setItem('theme', this.theme);
  }

  set(theme) {
    this.theme = theme;
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
  }

  get isDark() {
    return this.theme === 'dark';
  }
}

export const themeService = new ThemeService();
```

## AG Grid Theme Integration

Map design tokens to AG Grid variables in the theme files:

```css
[data-theme="dark"] {
  --ag-background-color: hsl(var(--app-card));
  --ag-foreground-color: hsl(var(--app-foreground));
  --ag-header-background-color: hsl(var(--app-background-alt));
  --ag-row-hover-color: hsl(var(--app-card-hover));
  --ag-border-color: hsl(var(--app-border));
  --ag-selected-row-background-color: hsl(var(--app-primary) / 0.15);
}
```

## Rules

1. **Never hardcode colors** — Always use CSS custom properties
2. **Use semantic variables** — `var(--primary)` not `hsl(212 92% 67%)`
3. **Test both themes** — Every component must work in dark and light mode
4. **HSL format** — Enables opacity: `hsl(var(--app-primary) / 0.5)`
5. **`--app-*` prefix** — All project tokens use the `--app-` namespace
