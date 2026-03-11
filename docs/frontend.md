# Frontend Architecture

## Overview

Single Page Application using Lit web components, hash-based routing, and CSS custom properties. No build step required for development.

## Lit Components

### Why Lit

- ~5KB, fast, reactive properties
- Standard Web Components under the hood
- Template literals with `html` and `css` tagged templates
- Works without build tools (dev), tree-shakeable (prod)

### Component File Structure

Each component lives in its own folder with 2 files:

```
components/ui/app-dialog/
├── app-dialog.js           # Component class + template
└── app-dialog.styles.js    # Styles (css tagged template)
```

### Component Implementation

```javascript
// components/ui/app-dialog/app-dialog.js
import { LitElement, html } from 'lit';
import { styles } from './app-dialog.styles.js';

export class AppDialog extends LitElement {
  static styles = styles;

  static properties = {
    open: { type: Boolean, reflect: true },
    heading: { type: String }
  };

  constructor() {
    super();
    this.open = false;
    this.heading = '';
  }

  render() {
    return html`
      <div class="overlay" ?hidden=${!this.open} @click=${this._onOverlayClick}>
        <div class="dialog">
          <header>${this.heading}</header>
          <slot></slot>
          <footer>
            <slot name="actions"></slot>
          </footer>
        </div>
      </div>
    `;
  }

  _onOverlayClick(e) {
    if (e.target === e.currentTarget) {
      this.dispatchEvent(new CustomEvent('dialog-close', { bubbles: true, composed: true }));
    }
  }
}

customElements.define('app-dialog', AppDialog);
```

```javascript
// components/ui/app-dialog/app-dialog.styles.js
import { css } from 'lit';

export const styles = css`
  :host {
    display: block;
  }

  .overlay {
    position: fixed;
    inset: 0;
    background: hsl(var(--app-background) / 0.8);
    display: grid;
    place-items: center;
    z-index: var(--app-z-modal);
  }

  .dialog {
    background: var(--app-card);
    border: 1px solid var(--app-border);
    border-radius: var(--app-radius-lg);
    padding: var(--app-space-6);
    min-width: 400px;
  }
`;
```

### Component Categories

| Category | Purpose | Example |
|----------|---------|---------|
| **UI Components** | Reusable, generic | `app-dialog`, `app-data-grid`, `app-toast` |
| **View Components** | Full pages, tied to routes | `settings-view`, `dashboard-view` |
| **Layout Components** | App shell, navigation | `app-sidebar`, `app-topnav` |

### Component Rules

- One folder per component in `components/ui/`
- Prefix with `app-` for project components
- Use Lit reactive properties, not manual DOM queries
- Dispatch `CustomEvent` for communication (bubbles + composed)
- Never hardcode colors — use `var(--app-*)`
- Clean up listeners in `disconnectedCallback()`

## Views (Pages)

A View is a Lit component representing a full page, tied to a route.

```
views/settings/
├── settings-view.js          # Lit component (the page)
└── settings-controller.js    # Plain JS class (the logic)
```

```javascript
// views/settings/settings-view.js
import { LitElement, html, css } from 'lit';
import { SettingsController } from './settings-controller.js';

export class SettingsView extends LitElement {
  static styles = css`
    :host { display: block; padding: var(--app-space-6); }
  `;

  constructor() {
    super();
    this.controller = new SettingsController(this);
  }

  connectedCallback() {
    super.connectedCallback();
    this.controller.init();
  }

  render() {
    return html`
      <h1>Settings</h1>
      <app-settings-form
        .data=${this.controller.settings}
        @settings-save=${this.controller.save}
      ></app-settings-form>
    `;
  }
}

customElements.define('settings-view', SettingsView);
```

### View Rules

- Views compose UI components — they don't implement reusable patterns
- Views have exactly one controller
- Views must not fetch data directly
- Views must not contain business logic

## Controllers

Plain JavaScript classes. One per view.

```javascript
// views/settings/settings-controller.js
import { apiService } from '../../services/api.js';

export class SettingsController {
  constructor(view) {
    this.view = view;
    this.settings = {};
  }

  async init() {
    this.settings = await apiService.get('/api/settings');
    this.view.requestUpdate();
  }

  save = async (e) => {
    await apiService.put('/api/settings', e.detail);
    this.view.requestUpdate();
  };
}
```

### Controller Rules

- No rendering, no DOM manipulation
- Call services for data
- Update view via `this.view.requestUpdate()`
- Handle user interactions
- Manage navigation

## Routing

### Hash-Based Routing

All routing uses hash fragments (`/#/path`). This guarantees:

- Deep linking works
- Page refresh preserves route
- No server-side route configuration needed
- Capacitor/mobile compatibility
- Bookmarkable URLs

### Router Setup

Using `@vaadin/router` (works with any Web Component):

```javascript
// app/router.js
import { Router } from '@vaadin/router';

const outlet = document.getElementById('app');
const router = new Router(outlet);

router.setRoutes([
  { path: '/',           component: 'dashboard-view' },
  { path: '/settings',   component: 'settings-view' },
  { path: '/settings/:section', component: 'settings-view' },
  { path: '/users',      component: 'users-view' },
  { path: '/users/:id',  component: 'user-detail-view' },
  { path: '(.*)',        component: 'not-found-view' }
]);
```

### Route Conventions

```
/#/                         Dashboard / home
/#/settings                 Settings page
/#/settings/profile         Settings sub-section
/#/resources                Resource list
/#/resources/:id            Resource detail
/#/resources/:id/edit       Resource edit
```

### Accessing Route Parameters

```javascript
// In a view's onBeforeEnter (Vaadin Router lifecycle)
onBeforeEnter(location) {
  this.resourceId = location.params.id;
}
```

### Navigation

```javascript
// Programmatic navigation
Router.go('/settings');

// In templates
html`<a href="/#/settings">Settings</a>`;
```

## Services

Frontend services encapsulate I/O and shared state.

```
services/
├── api.js        # HTTP client for backend API
├── auth.js       # Auth state and tokens
└── storage.js    # Local storage abstraction
```

### API Service

```javascript
// services/api.js
class ApiService {
  constructor() {
    this.baseUrl = '/api';
  }

  async request(method, path, body) {
    const headers = { 'Content-Type': 'application/json' };
    const token = localStorage.getItem('access_token');
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const response = await fetch(`${this.baseUrl}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined
    });

    const data = await response.json();
    if (!data.success) throw new Error(data.error);
    return data.data;
  }

  get(path) { return this.request('GET', path); }
  post(path, body) { return this.request('POST', path, body); }
  put(path, body) { return this.request('PUT', path, body); }
  delete(path) { return this.request('DELETE', path); }
}

export const apiService = new ApiService();
```

## Data Grids

All tabular data uses AG Grid Community, wrapped in a Lit component.

```javascript
// components/ui/app-data-grid/app-data-grid.js
import { LitElement, html, css } from 'lit';
import { createGrid } from 'ag-grid-community';

export class AppDataGrid extends LitElement {
  // Wraps AG Grid with consistent theming and behavior
}

customElements.define('app-data-grid', AppDataGrid);
```

Rules:
- Never create custom HTML tables for data
- Always use the `app-data-grid` wrapper
- AG Grid Community (free) is sufficient — upgrade path exists
